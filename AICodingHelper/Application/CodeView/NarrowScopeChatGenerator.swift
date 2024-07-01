//
//  AICodingHelperServerNetworkClient.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 6/28/24.
//

import CodeEditor
import Foundation


class NarrowScopeChatGenerator: ObservableObject {
    
    @Published var streamingChat: String?
    @Published var streamingChatDelta: String?
    @Published var streamingChatScope: Scope?
    @Published var isLoading: Bool = false
    @Published var isStreaming: Bool = false
    
    
    func streamChat(authToken: String, model: GPTModels, action: ActionType, additionalInput: String?, language: CodeEditor.Language?, responseFormat: ResponseFormatType = .text, context: [String], input: String, scope: Scope) async throws {
        /* Should look something like
         System
            You are an AI coding helper service in an IDE so you must format all your responses in <language> code that would be valid in an IDE.
         User Message 1
            You are an AI coding helper in an IDE so all responses must be in <language> code that would be valid in an IDE.
            Here are other files from my projet to reference
            <Project Files>
         User Message 2
            You are an AI coding helper in an IDE so all responses must be in <language> code that would be valid in an IDE.
            <Action AI Prompt>
            <Additional Input>
            <Code>
         */
        
        let systemMessage = "You are an AI coding helper service in an IDE so you must format all your responses in \(language == nil ? "" : "\(language!.rawValue)") code that would be valid in an IDE. Do not include ```LanguageName or ``` to denote code. You only respond with code that is valid in that language."
        let userMessage1 = {
            var userMessage1_1 = "You are an AI coding helper in an IDE so all responses must be in \(language == nil ? "" : "\(language!.rawValue)") code that would be valid in an IDE."
            var userMessage1_2 = "Here are other files from my project to reference"
            return ([userMessage1_1, userMessage1_2] + context).joined(separator: "\n")
        }()
        let userMessage2 = {
            var userMessage2_1 = "You are an AI coding helper in an IDE so all responses must be in \(language == nil ? "" : "in \(language!.rawValue) code") code that would be valid in an IDE."
            var userMessage2_2 = action.aiPrompt
            return [userMessage2_1, userMessage2_2, input].joined(separator: "\n")
        }()
        
        try await streamChat(
            authToken: authToken,
            model: model,
            responseFormat: responseFormat,
            systemMessage: systemMessage,
            userInputs: [userMessage1, userMessage2],
            scope: scope)
    }
    
    func streamChat(authToken: String, model: GPTModels, responseFormat: ResponseFormatType, systemMessage: String?, userInputs: [String], scope: Scope) async throws {
        // Create messages and add messages
        var messages: [OAIChatCompletionRequestMessage] = []
        
        // Add systemMessage if not nil
        if let systemMessage = systemMessage {
            messages.append(OAIChatCompletionRequestMessage(
                role: .system,
                content: [.text(OAIChatCompletionRequestMessageContentText(text: systemMessage))]))
        }
        
        // Add userInputs messages
        for userInput in userInputs {
            messages.append(OAIChatCompletionRequestMessage(
                role: .user,
                content: [.text(OAIChatCompletionRequestMessageContentText(text: userInput))]))
        }
        
        // Create getChatRequest
        let getChatRequest = GetChatRequest(
            authToken: authToken,
            chatCompletionRequest: OAIChatCompletionRequest(
                model: model.rawValue,
                responseFormat: OAIChatCompletionRequestResponseFormat(type: .text),
                stream: true,
                messages: messages))
        
        // Stream chat
        try await streamChat(getChatRequest: getChatRequest, scope: scope)
    }
    
    func streamChat(getChatRequest: GetChatRequest, scope: Scope) async throws {
        // Ensure not loading or streaming, otherwise return
        guard !isLoading && !isStreaming else {
            // TODO: Handle Errors
            print("Could not stream chat because another chat is currently streaming!")
            return
        }
        
        // Reset current chat and set scope
        await MainActor.run {
            streamingChat = nil
            streamingChatScope = scope
        }
        
        // Defer setting isLoading and isStreaming to false
        defer {
            DispatchQueue.main.async {
                self.isLoading = false
                self.isStreaming = false
            }
        }
        
        // Set isLoading to true
        await MainActor.run {
            isLoading = true
        }
        
        // Encode getChatRequest to string, otherwise return
        guard let requestString = String(data: try JSONEncoder().encode(getChatRequest), encoding: .utf8) else {
            // TODO: Handle Errors
            print("Could not unwrap encoded getChatRequest to String in AICodingHelperServerNetworkClient!")
            return
        }
        
        // Get stream
        let stream = AICodingHelperWebSocketConnector.getStream()
        
        // Send GetChatRequest to stream
        try await stream.send(.string(requestString))
        
        // Parse stream response
        var firstMessage: Bool = true
        do {
            for try await message in stream {
                if firstMessage {
                    // Set isLoading to false and isStreaming to true
                    await MainActor.run {
                        isLoading = false
                        isStreaming = true
                    }
                    
                    // Set firstMessage to false
                    firstMessage = false
                }
                
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
                
                // Update streamingChat and streamingChatDelta
                await MainActor.run {
                    if let zeroIndexChoice = getChatResponse.body.oaiResponse.choices[safe: 0],
                       let content = zeroIndexChoice.delta.content {
                        if streamingChat == nil {
                            streamingChat = content
                        } else {
                            streamingChat! += content
                        }
                        
                        streamingChatDelta = content
                    }
                }
            }
        } catch {
            // TODO: Handle Errors, though this may be normal
            print("Error parsing stream response in AICodingHelperNetworkClient... \(error)")
        }
    }
    
}
