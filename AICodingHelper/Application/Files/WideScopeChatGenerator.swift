//
//  WideScopeChatGenerator.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/1/24.
//

import Foundation


class WideScopeChatGenerator: ObservableObject {
    
    @Published var isLoading: Bool = false
    
    
//    func refactorSelectedItems(authToken: String, model: GPTModels, action: ActionType, selectedItemPaths: [String], copyCurrentFilesToTempFiles: Bool) async throws { TODO: The FileSystem may be parsed by the caller, however it could also I guess be parsed here lol
//
//    }
    
    func refactorProject(action: ActionType, userInput: String?, rootDirectoryPath: String, options: GenerateOptions) {
        // Create FileSystem from root directory, otherwise reutrn
        guard let rootDirectoryFileSystem = FileSystem.from(path: rootDirectoryPath) else {
            // TODO: Handle Errors
            print("Error unwrapping baseDirectoryFileSystem in FileBrowserView!")
            return
        }
        
        // Refactor Files
        refactorFiles(
            action: action,
            userInput: userInput,
            rootDirectoryPath: rootDirectoryPath,
            rootFile: rootDirectoryFileSystem,
            alternativeContextFiles: nil,
            options: options)
    }
    
    func refactorFiles(action: ActionType, userInput: String?, rootDirectoryPath: String, rootFile: FileSystem, alternativeContextFiles: FileSystem?, options: GenerateOptions) {
        Task {
            // Create additionalInput from userInput TODO: Add this
            let additionalInput = userInput
            
            // Ensure authToken
            let authToken: String
            do {
                authToken = try await AuthHelper.ensure()
            } catch {
                // TODO: Handle Errors
                print("Error ensuring authToken in MainView... \(error)")
                return
            }
            
            // Refactor files
            do {
                try await refactorFiles(
                    authToken: authToken,
                    model: .GPT4o,
                    action: action,
                    additionalInput: additionalInput,
                    rootDirectoryPath: rootDirectoryPath,
                    rootFile: rootFile,
                    alternativeContextFiles: alternativeContextFiles,
                    options: options)
            }
        }
    }
    
    
    func refactorFiles(authToken: String, model: GPTModels, action: ActionType, additionalInput: String?, rootDirectoryPath: String, rootFile: FileSystem, alternativeContextFiles: FileSystem?, options: GenerateOptions) async throws {
        /* Should look something like
         System
            You are an AI coding helper service in an IDE so you must format all your responses in code that would be valid in an IDE.
         User Message 1
            You are an AI coding helper in an IDE so all responses must be in code that would be valid in an IDE.
            -- if using alternative context files, which would be something like the project files
                Here are other files in my project to reference
                <Project Files>
            -- if not using alternative context files and therefore just using selection as context
                Here are other files included in the selection to eventually be refactored, for reference purposes.
                <Selected Files>
         User Message 2
            You are an AI coding helper in an IDE so all responses must be in code that would be valid in an IDE.
            <Action AI Prompt>
            <Additional Input>
            <Code>
         */
        
        // Get context string from files as alternativeContextFiles if not nil, otherwise from rootFile
        let contextString = alternativeContextFiles == nil ? rootFile.stringifyContent(rootDirectory: rootDirectoryPath) : alternativeContextFiles!.stringifyContent(rootDirectory: rootDirectoryPath)
        
        // Parse and assemble systemMessage and parse and add context String from alternativeContextFiles or if nil files
        let systemMessage = "You are an AI coding helper service in an IDE so you must format all your responses in code that would be valid in an IDE. Do not include ```LanguageName or ``` to denote code. You only respond with code that is valid in that language."
        let userMessage1 = {
            let userMessage1_1 = "You are an AI coding helper in an IDE so all responses must be in code that would be valid in an IDE."
            let userMessage1_2 = alternativeContextFiles == nil ? "Here are other files included in the selection to eventually be refactored, for reference purposes" : "Here aer other files in my project to reference"
            return [userMessage1_1, userMessage1_2, contextString].joined(separator: "\n")
        }()
        
        // Refactor Files
        try await refactorFiles(
            authToken: authToken,
            model: model,
            action: action,
            additionalInput: additionalInput,
            rootDirectoryPath: rootDirectoryPath,
            rootFile: rootFile,
            systemMessage: systemMessage,
            context: [userMessage1],
            options: options)
    }
    
    func refactorFiles(authToken: String, model: GPTModels, action: ActionType, additionalInput: String?, rootDirectoryPath: String, rootFile: FileSystem, systemMessage: String, context: [String], options: GenerateOptions) async throws {
        // Get current item path by rootDirectoryPath / and file name
        let currentItemPath = rootDirectoryPath + "/" + rootFile.name
        
        // If file has subfiles recursively call refactorFiles for each file in it updating rootDirectoryPath adding the current file's name and return
        if let subfiles = rootFile.subfiles {
            // Refactor each file in rootFile subsfiles
            for file in subfiles {
                do {
                    try await refactorFiles(
                        authToken: authToken,
                        model: model,
                        action: action,
                        additionalInput: additionalInput,
                        rootDirectoryPath: currentItemPath,
                        rootFile: file,
                        systemMessage: systemMessage,
                        context: context,
                        options: options)
                } catch {
                    // TODO: Handle Errors
                    print("Error refactoring file in WideScopeChatGenerator... \(error)")
                }
            }
            
            return
        }
        
        // Get file contents using currentItemPath
        let fileContents = try String(contentsOfFile: currentItemPath)
        
        // Create input from action, additionalInput, and fileContents
        let input: String = {
            /*
             Should be
             You are an AI coding helper in an IDE so all responses must be in code that would be valid in an IDE.
             <Action AI Prompt>
             <Additional Input>
             <Code>
             */
            var input = action.aiPrompt
            if let additionalInput = additionalInput {
                input += additionalInput
            }
            input += fileContents
            return input
        }()
        
        // Get chat with userInputs as context with input at the bottom
        let fileChatResponse = try await getChat(
            authToken: authToken,
            model: model,
            systemMessage: systemMessage,
            userInputs: context + [input])
        
        // If copyCurrentFilesToTempFiles copy file to new file with _temp# suffixed name
        if options.contains(.copyCurrentFilesToTempFiles) {
            try FileCopier.copyFileToTempVersion(at: currentItemPath)
        }
        
        // Set file text to chat
        try fileChatResponse?.write(
            toFile: currentItemPath,
            atomically: true,
            encoding: .utf8)
    }
    
    
    private func getChat(authToken: String, model: GPTModels, systemMessage: String?, userInputs: [String]) async throws -> String? {
        // Create inputMessages array
        var inputMessages: [OAIChatCompletionRequestMessage] = []
        
        // Create and append system message
        if let systemMessage = systemMessage {
            inputMessages.append(
                OAIChatCompletionRequestMessage(
                    role: .system,
                    content: [
                        .text(OAIChatCompletionRequestMessageContentText(text: systemMessage))
                    ])
            )
        }
        
        // Create and append messages from userInputs
        for userInput in userInputs {
            inputMessages.append(
                OAIChatCompletionRequestMessage(
                role: .user,
                content: [
                    .text(OAIChatCompletionRequestMessageContentText(text: userInput))
                ])
            )
        }
        
        // Create GetChatRequest
        let getChatRequest = GetChatRequest(
            authToken: authToken,
            chatCompletionRequest: OAIChatCompletionRequest(
                model: model.rawValue,
                stream: true,
                messages: inputMessages))
        
        // Return getChat
        return try await getChat(getChatRequest: getChatRequest)
    }
    
    private func getChat(getChatRequest: GetChatRequest) async throws -> String? {
//        guard !isLoading else {
//            // TODO: Handle Errors
//            print("Could not get chat because another chat is currently loading!")
//            return nil
//        }
//        
//        // Defer setting isLoading to false
//        defer {
//            DispatchQueue.main.async {
//                self.isLoading = false
//            }
//        }
//        
//        // Set isLoading to true
//        await MainActor.run {
//            isLoading = true
//        }
        
        // Encode getChatRequest to string, otherwise return
        guard let requestString = String(data: try JSONEncoder().encode(getChatRequest), encoding: .utf8) else {
            // TODO: Handle Errors
            print("Could not unwrap encoded getChatRequest to String in AICodingHelperServerNetworkClient!")
            return nil
        }
        
        // Get stream
        let stream = AICodingHelperWebSocketConnector.getStream()
        
        // Send GetChatRequest to stream
        try await stream.send(.string(requestString))
        
        // Parse stream response
        var responseContent: String = ""
        do {
            for try await message in stream {
                // Parse message, and if it cannot be unwrapped continue
                guard let messageData = {
                    switch message {
                    case .data(let data):
                        return data
                    case .string(let string):
                        return string.data(using: .utf8)
                    @unknown default:
                        print("Message wasn't stirng or data when parsing message stream! :O")
                        return nil
                    }
                }() else {
                    print("Could not unwrap messageData in message stream! Skipping...")
                    continue
                }
                
                // Parse message to GetChatResponse
                let getChatResponse: GetChatResponse
                do {
                    getChatResponse = try JSONDecoder().decode(GetChatResponse.self, from: messageData)
                } catch {
                    print("Error decoding messageData to GetChatResponse so skipping... \(error)")
                    
                    // Catch as StatusResponse
                    let statusResponse = try JSONDecoder().decode(StatusResponse.self, from: messageData)
                    
                    if statusResponse.success == 5 {
                        Task {
                            do {
                                try await AuthHelper.regenerate()
                            } catch {
                                print("Error regenerating authToken in HTTPSConnector... \(error)")
                            }
                        }
                    }
                    continue
                }
                
                // Add response content to responseContent
                if let zeroIndexChoice = getChatResponse.body.oaiResponse.choices[safe: 0],
                   let content = zeroIndexChoice.delta.content {
                    responseContent += content
                }
            }
        } catch {
            // TODO: Handle Errors, though this may be normal
            print("Error parsing stream response in AICodingHelperNetworkClient... \(error)")
        }
        
        // Return responseContent
        return responseContent
    }
    
}
