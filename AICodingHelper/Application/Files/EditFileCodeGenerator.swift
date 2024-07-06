//
//  WideScopeChatGenerator.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/1/24.
//

import Foundation


class EditFileCodeGenerator {
    
    static func refactorFiles(authToken: String, wideScopeChatGenerationTask: CodeGenerationTask, progressTracker: ProgressTracker) async throws {
        // Start progress tracker estimation with totalTasks as filepathCodeGenerationPrompts count
        DispatchQueue.main.async {
            progressTracker.startEstimation(totalTasks: wideScopeChatGenerationTask.filepathCodeGenerationPrompts.count)
        }
        
        for filepathCodeGenerationPrompt in wideScopeChatGenerationTask.filepathCodeGenerationPrompts {
            // Refactor file
            do {
                try await refactorFile(
                    authToken: authToken,
                    filepathCodeGenerationPrompt: filepathCodeGenerationPrompt,
                    copyCurrentFileToTempFile: wideScopeChatGenerationTask.copyCurrentFilesToTempFiles)
            } catch {
                print("Error refactoring file in WideScopeChatGenerator, continuing with other files... \(error)")
            }
            
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
    }
    
    /**
     Refactor File
     
     Automatically uses filepaths as context unless alternateContextFilepaths are specified
     */
    static func refactorFile(authToken: String, model: GPTModels, additionalInput: String, filepath: String, systemMessage: String, context: [String], copyCurrentFileToTempFile: Bool) async throws {
        // Get file contents using currentItemPath
        let fileContents = try String(contentsOfFile: filepath)
        
        // Create promptInput from additionalInput \n fileContents
        let promptInput = additionalInput + fileContents
        
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
