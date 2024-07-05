//
//  WideScopeChatGenerator.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/1/24.
//

import Foundation


class WideScopeChatGenerator {
    
    struct WideScopeChatGenerationTask {
        
        var filepathCodeGenerationPrompts: [FilepathCodeGenerationPrompt]
        var copyCurrentFilesToTempFiles: Bool
        
    }
    
    
    static func refactorFiles(authToken: String, wideScopeChatGenerationTask: WideScopeChatGenerationTask, progressTracker: ProgressTracker) async throws {
        // Start progress tracker estimation with totalTasks as filepathCodeGenerationPrompts count
        DispatchQueue.main.async {
            progressTracker.startEstimation(totalTasks: wideScopeChatGenerationTask.filepathCodeGenerationPrompts.count)
        }
        
        for filepathCodeGenerationPrompt in wideScopeChatGenerationTask.filepathCodeGenerationPrompts {
            // Refactor file
            try await refactorFile(
                authToken: authToken,
                filepathCodeGenerationPrompt: filepathCodeGenerationPrompt,
                copyCurrentFileToTempFile: wideScopeChatGenerationTask.copyCurrentFilesToTempFiles)
            
            // Complete task for progressTracker
            DispatchQueue.main.async {
                progressTracker.completeTask()
            }
        }
    }
    
    static func refactorFile(authToken: String, filepathCodeGenerationPrompt: FilepathCodeGenerationPrompt, copyCurrentFileToTempFile: Bool) async throws {
        // Refactor files
        try await refactorFile(
            authToken: authToken,
            model: filepathCodeGenerationPrompt.model,
            additionalInput: filepathCodeGenerationPrompt.additionalInput,
            filepath: filepathCodeGenerationPrompt.filepath,
            systemMessage: filepathCodeGenerationPrompt.systemMessage,
            context: filepathCodeGenerationPrompt.context,
            copyCurrentFileToTempFile: copyCurrentFileToTempFile)
        
//        try await refactorFile(
//            authToken: authToken,
//            model: filepathCodeGenerationPrompt.model,
//            action: filepathCodeGenerationPrompt.action,
//            additionalInput: filepathCodeGenerationPrompt.additionalInput,
//            filepaths: filepathCodeGenerationPrompt.filepaths,
//            alternateContextFilepaths: filepathCodeGenerationPrompt.additionalContextFilepaths,
//            options: filepathCodeGenerationPrompt.options,
//            progressTracker: progressTracker)
    }
    
//    static func refactorFiles(authToken: String, remainingTokens: Int, action: ActionType, userInput: String?, filepaths: [String], alternateContextFilepaths: [String]?, options: GenerateOptions, progressTracker: ProgressTracker) async throws {
//        // Create additionalInput from userInput TODO: Add this
//        let additionalInput = userInput
//        
//        // Refactor files
//        try await refactorFiles(
//            authToken: authToken,
//            remainingTokens: remainingTokens,
//            model: .GPT4o,
//            action: action,
//            additionalInput: additionalInput,
//            filepaths: filepaths,
//            alternateContextFilepaths: alternateContextFilepaths,
//            options: options,
//            progressTracker: progressTracker)
//    }
    
//    static func refactorFiles(authToken: String, model: GPTModels, action: ActionType, additionalInput: String?, filepaths: [String], alternateContextFilepaths: [String]?, options: GenerateOptions, progressTracker: ProgressTracker) async throws {
//        
//        
//        // Estimate tokens with action + systemMessage + userMessage1 + additionalInput + filepath content for each filepath
//        var estimatedTokens: Int = await TokenCalculator.getEstimatedTokens(
//            authToken: authToken,
//            filepaths: filepaths,
//            contextForEachFile: [action.aiPrompt, systemMessage, userMessage1, additionalInput ?? ""].joined(separator: "\n"))
//        
//        // If estimatedTokens is greater than remainingTokens throw GenerationError estimatedTokensHitsLimit
//        if estimatedTokens > remainingTokens {
//            throw GenerationError.estimatedTokensHitsLimit
//        }
//        
//        // Refactor Files
//        try await refactorFiles(
//            authToken: authToken,
//            model: model,
//            action: action,
//            additionalInput: additionalInput,
//            filepaths: filepaths,
//            systemMessage: systemMessage,
//            context: [userMessage1],
//            options: options,
//            progressTracker: progressTracker)
//    }
    
    /**
     Refactor File
     
     Automatically uses filepaths as context unless alternateContextFilepaths are specified
     */
    static func refactorFile(authToken: String, model: GPTModels, additionalInput: String, filepath: String, systemMessage: String, context: [String], copyCurrentFileToTempFile: Bool) async throws {
//        // If file is directory, loop through each file and call refactorFile with it - Directories will not be in the generation prompt now
//        var isDirectory: ObjCBool = false
//        if FileManager.default.fileExists(atPath: filepath, isDirectory: &isDirectory) {
//            if isDirectory.boolValue {
//                do {
//                    let subfiles = try FileManager.default.contentsOfDirectory(atPath: filepath)
//                    for subfile in subfiles {
//                        let subfilePath = (filepath as NSString).appendingPathComponent(subfile)
//                        
//                        try await refactorFile(
//                            authToken: authToken,
//                            model: model,
//                            action: action,
//                            additionalInput: additionalInput,
//                            filepath: subfilePath,
//                            systemMessage: systemMessage,
//                            context: context,
//                            options: options,
//                            progressTracker: progressTracker)
//                    }
//                } catch {
//                    // TODO: Handle Errors
//                    print("Error getting subfiles from directory in WideScopeChatGenerator... \(error)")
//                }
//            }
//        }
        
        // Get file contents using currentItemPath
        let fileContents = try String(contentsOfFile: filepath)
        
        // Create promptInput from additionalInput \n fileContents
        let promptInput = additionalInput + fileContents
        
//        // Create input from action, additionalInput, and fileContents
//        let input: String = {
//            /*
//             Should be
//             You are an AI coding helper in an IDE so all responses must be in code that would be valid in an IDE.
//             <Action AI Prompt>
//             <Additional Input>
//             <Code>
//             */
//            var input = action.aiPrompt
//            if let additionalInput = additionalInput {
//                input += additionalInput
//            }
//            input += fileContents
//            return input
//        }()
        
        // Get chat with userInputs as context with promptInput at the bottom
        let fileChatResponse = try await getChat(
            authToken: authToken,
            model: model,
            systemMessage: systemMessage,
            userInputs: context + [promptInput])
        
        // If copyCurrentFileToTempFile copy file to new file with _temp# suffixed name
        if copyCurrentFileToTempFile {
            try FileCopier.copyFileToTempVersion(at: filepath)
        }
        
        // Set file text to chat
        try fileChatResponse?.write(
            toFile: filepath,
            atomically: true,
            encoding: .utf8)
    }
        
    
    
    private static func getChat(authToken: String, model: GPTModels, systemMessage: String?, userInputs: [String]) async throws -> String? {
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
    
    private static func getChat(getChatRequest: GetChatRequest) async throws -> String? {
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
