////
////  FileSystemGenerator.swift
////  AICodingHelper
////
////  Created by Alex Coundouriotis on 6/30/24.
////
//
//import Foundation
//import SwiftUI
//
//
//class FileSystemGenerator: ObservableObject {
//    
//    @Published var isLoading: Bool = false
//    
//    
//    func getFileSystem(authToken: String, model: GPTModels, input: String, fileSystem: FileSystem) async throws -> FileSystem? {
//        /***
//         Should be
//         Input
//         FileSystem JSON\nFileSystem JSON
//         */
//        // Ensure get and unwrap String from fileSystem, otherwise return nil
//        guard var fileSystemString = String(data: try JSONEncoder().encode(fileSystem), encoding: .utf8) else {
//            return nil
//        }
//        
//        fileSystemString.insert(contentsOf: "FileSystem JSON\n", at: fileSystemString.startIndex)
//        
//        // Return getChat setting userInputs to input and fileSystemString
//        return try await getChat(
//            authToken: authToken,
//            model: model,
//            userInputs: [
//                input,
//                fileSystemString
//            ])
//    }
//    
//    private func getChat(authToken: String, model: GPTModels, userInputs: [String]) async throws -> FileSystem? {
//        // Create messages from userInputs
//        var inputMessages: [OAIChatCompletionRequestMessage] = []
//        for userInput in userInputs {
//            inputMessages.append(
//                OAIChatCompletionRequestMessage(
//                role: .user,
//                content: [
//                    .text(OAIChatCompletionRequestMessageContentText(text: userInput))
//                ])
//                )
//        }
//        
//        // Build GetChatRequest
//        let getChatRequest = GetChatRequest(
//            authToken: authToken,
//            chatCompletionRequest: OAIChatCompletionRequest(
//                model: model.rawValue,
//                responseFormat: OAIChatCompletionRequestResponseFormat(type: .jsonObject),
//                stream: true,
//                messages: inputMessages))
//        
//        // Get and ensure unwrap response, otherwise return nil
//        guard let response = try await getChat(getChatRequest: getChatRequest) else {
//            return nil
//        }
//        
//        // Ensure unwrap response as data, otherwise return nil
//        guard let responseData = response.data(using: .utf8) else {
//            return nil
//        }
//        
//        // Parse response to FileSystem and return
//        return try JSONDecoder().decode(FileSystem.self, from: responseData)
//    }
//    
//    
//    private func getChat(getChatRequest: GetChatRequest) async throws -> String? {
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
//        
//        // Encode getChatRequest to string, otherwise return
//        guard let requestString = String(data: try JSONEncoder().encode(getChatRequest), encoding: .utf8) else {
//            // TODO: Handle Errors
//            print("Could not unwrap encoded getChatRequest to String in AICodingHelperServerNetworkClient!")
//            return nil
//        }
//        
//        // Get stream
//        let stream = AICodingHelperWebSocketConnector.getStream()
//        
//        // Send GetChatRequest to stream
//        try await stream.send(.string(requestString))
//        
//        // Parse stream response
//        var responseContent: String = ""
//        do {
//            for try await message in stream {
//                // Parse message, and if it cannot be unwrapped continue
//                guard let messageData = {
//                    switch message {
//                    case .data(let data):
//                        return data
//                    case .string(let string):
//                        return string.data(using: .utf8)
//                    @unknown default:
//                        print("Message wasn't stirng or data when parsing message stream! :O")
//                        return nil
//                    }
//                }() else {
//                    print("Could not unwrap messageData in message stream! Skipping...")
//                    continue
//                }
//                
//                // Parse message to GetChatResponse
//                let getChatResponse: GetChatResponse
//                do {
//                    getChatResponse = try JSONDecoder().decode(GetChatResponse.self, from: messageData)
//                } catch {
//                    print("Error decoding messageData to GetChatResponse so skipping... \(error)")
//                    
//                    // Catch as StatusResponse
//                    let statusResponse = try JSONDecoder().decode(StatusResponse.self, from: messageData)
//                    
//                    if statusResponse.success == 5 {
//                        Task {
//                            do {
//                                try await AuthHelper.regenerate()
//                            } catch {
//                                print("Error regenerating authToken in HTTPSConnector... \(error)")
//                            }
//                        }
//                    }
//                    continue
//                }
//                
//                // Add response content to responseContent
//                if let zeroIndexChoice = getChatResponse.body.oaiResponse.choices[safe: 0],
//                   let content = zeroIndexChoice.delta.content {
//                    responseContent += content
//                }
//            }
//        } catch {
//            // TODO: Handle Errors, though this may be normal
//            print("Error parsing stream response in AICodingHelperNetworkClient... \(error)")
//        }
//        
//        // Return responseContent
//        return responseContent
//    }
//    
//}
