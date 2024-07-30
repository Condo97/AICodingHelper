//
//  DiscussionGenerator.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/29/24.
//

import Foundation


class DiscussionGenerator: ObservableObject {
    
    @Published var discussion: Discussion
    
    @Published var isLoading: Bool = false
    @Published var newInput: String = ""
    @Published var newFilepaths: [String] = []
    @Published var streamingChat: String = ""
    
    @Published var chatGenerator: ChatGenerator?
    @Published var generateCodeFCAICodingHelperHTTPSConnector: AICodingHelperHTTPSConnector?
    
    private var streamingFunction: String = ""
    
    init(discussion: Discussion) {
        self.discussion = discussion
    }
    
    func doBuildCodeGeneration(activeSubscriptionUpdater: ActiveSubscriptionUpdater, rootFilepath: String) {
        // Ensure is not loading, otherwise return
        guard !isLoading else {
            // TODO: Handle Errors
            return
        }
        
        // Create chat with newInput and newFilepaths and append to discussion chats if not empty
        if !newInput.isEmpty || !newFilepaths.isEmpty {
            discussion.chats.append(
                Chat(
                    role: .user,
                    message: newInput,
                    referenceFilepaths: newFilepaths.isEmpty ? nil : newFilepaths)
            )
        }
        
        // Reset newInput and newFilepaths
        newInput = ""
        newFilepaths = []
        
        // Generate geneate code FC chat
        Task {
            await generateGenerateCodeFCChat(
                activeSubscriptionUpdater: activeSubscriptionUpdater,
                rootFilepath: rootFilepath)
        }
    }
    
    func doChatGeneration(activeSubscriptionUpdater: ActiveSubscriptionUpdater, rootFilepath: String) {
        // Ensure is not loading otherwise return
        guard !isLoading else {
            // TODO: Handle Errors
            return
        }
        
        // Ensure either newInput or newFilepaths are not empty, otherwise return
        guard !newInput.isEmpty || !newFilepaths.isEmpty else {
            // TODO: Handle Errors
            return
        }
        
        // Create chat with newInput and newFilepaths and append to discussion
        discussion.chats.append(
            Chat(
                role: .user,
                message: newInput,
                referenceFilepaths: newFilepaths.isEmpty ? nil : newFilepaths)
        )
        
        // Reset newInput and newFilepaths
        newInput = ""
        newFilepaths = []
        
        // Generate string chat
        Task {
            await generateStringChat(
                activeSubscriptionUpdater: activeSubscriptionUpdater,
                rootFilepath: rootFilepath)
        }
    }
    
    func generateStringChat(activeSubscriptionUpdater: ActiveSubscriptionUpdater, rootFilepath: String) async {
        // Ensure not isLoading
        guard !isLoading else {
            // TODO: Handle Errors
            return
        }
        
        // Defer setting isLoading to false
        defer {
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
        
        // Set isLoading to true
        await MainActor.run {
            isLoading = true
        }
        
        // Ensure unwrap authToken
        let authToken: String
        do {
            authToken = try await AuthHelper.ensure()
        } catch {
            // TODO: Handle Errors
            print("Error ensuring authToken in DiscussionView... \(error)")
            return
        }
        
        // Transform discussion chats to messages
        let messages: [OAIChatCompletionRequestMessage]
        do {
            messages = try discussion.chats.compactMap({
                // Transform reference filepaths into a string for the message
                let referenceFilepathsString: String? = $0.referenceFilepaths?.compactMap({
                    FilePrettyPrinter.getFileContent(relativeFilepath: $0, rootFilepath: rootFilepath)
                }).joined(separator: "\n\n")
                
                // If message is GenerateCodeFC transform and return
                if let message = $0.message as? GenerateCodeFC,
                   let messageString = String(data: try JSONEncoder().encode(message), encoding: .utf8) {
                    let finalMessage = messageString + (referenceFilepathsString == nil ? "" : ("\n\n" + referenceFilepathsString!))
                    
                    return OAIChatCompletionRequestMessage(
                        role: $0.role,
                        content: [
                            .text(OAIChatCompletionRequestMessageContentText(text: finalMessage))
                        ])
                }
                
                // If message is String transform and return
                if let message = $0.message as? String {
                    let finalMessage = message + (referenceFilepathsString == nil ? "" : ("\n\n" + referenceFilepathsString!))
                    
                    return OAIChatCompletionRequestMessage(
                        role: $0.role,
                        content: [
                            .text(OAIChatCompletionRequestMessageContentText(text: finalMessage))
                        ])
                }
                
                return nil
            })
        } catch {
            // TODO: Handle Errors
            print("Error transforming discussion chats to messages in DiscussionView... \(error)")
            return
        }
        
        // Get openAIKey
        let openAIKey = activeSubscriptionUpdater.openAIKeyIsValid ? activeSubscriptionUpdater.openAIKey : nil
        
        // Build getChatRequest
        let getChatRequest = GetChatRequest(
            authToken: authToken,
            openAIKey: openAIKey,
            chatCompletionRequest: OAIChatCompletionRequest(
                model: GPTModels.GPT4o.rawValue,
                stream: true,
                messages: messages))
        
        // Reset streamingChat
        await MainActor.run {
            streamingChat = ""
        }
        
        // Stream chat and set chatGenerator
        do {
            let chatGenerator = ChatGenerator()
            await MainActor.run {
                self.chatGenerator = chatGenerator
            }
            try await chatGenerator.streamChat(
                getChatRequest: getChatRequest,
                stream: { getChatResponse in
                    if let responseMessageDelta = getChatResponse.body.oaiResponse.choices[safe: 0]?.delta.content {
                        streamingChat += responseMessageDelta
                    }
                })
        } catch {
            // TODO: Handle Errors
            print("Error streaming chat in DiscussionView... \(error)")
        }
        
        // Create new chat and append to discussion and reset streamingChat
        await MainActor.run {
            let chat = Chat(
                role: .assistant,
                message: streamingChat)
            discussion.chats.append(chat)
            streamingChat = ""
        }
    }
    
    func generateGenerateCodeFCChat(activeSubscriptionUpdater: ActiveSubscriptionUpdater, rootFilepath: String) async {
        // Ensure not isLoading
        guard !isLoading else {
            // TODO: Handle Errors
            return
        }
        
        // Defer setting isLoading to false
        defer {
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
        
        // Set isLoading to true
        await MainActor.run {
            isLoading = true
        }
        
        // Ensure unwrap authToken
        let authToken: String
        do {
            authToken = try await AuthHelper.ensure()
        } catch {
            // TODO: Handle Errors
            print("Error ensuring authToken in DiscussionView... \(error)")
            return
        }
        
        // Transform discussion chats to messages
        let messages: [OAIChatCompletionRequestMessage]
        do {
            messages = try discussion.chats.compactMap({
                // Transform reference filepaths into a string for the message
                let referenceFilepathsString: String? = $0.referenceFilepaths?.compactMap({
                    FilePrettyPrinter.getFileContent(relativeFilepath: $0, rootFilepath: rootFilepath)
                }).joined(separator: "\n\n")
                
                // If message is GenerateCodeFC transform and return
                if let message = $0.message as? GenerateCodeFC,
                   let messageString = String(data: try JSONEncoder().encode(message), encoding: .utf8) {
                    let finalMessage = messageString + (referenceFilepathsString == nil ? "" : ("\n\n" + referenceFilepathsString!))
                    
                    return OAIChatCompletionRequestMessage(
                        role: $0.role,
                        content: [
                            .text(OAIChatCompletionRequestMessageContentText(text: finalMessage))
                        ])
                }
                
                // If message is String transform and return
                if let message = $0.message as? String {
                    let finalMessage = message + (referenceFilepathsString == nil ? "" : ("\n\n" + referenceFilepathsString!))
                    
                    return OAIChatCompletionRequestMessage(
                        role: $0.role,
                        content: [
                            .text(OAIChatCompletionRequestMessageContentText(text: finalMessage))
                        ])
                }
                
                return nil
            })
        } catch {
            // TODO: Handle Errors
            print("Error transforming discussion chats to messages in DiscussionView... \(error)")
            return
        }
        
        // Get openAIKey
        let openAIKey = activeSubscriptionUpdater.openAIKeyIsValid ? activeSubscriptionUpdater.openAIKey : nil
        
        // Build getChatRequest
        let getChatRequest = GetChatRequest(
            authToken: authToken,
            openAIKey: openAIKey,
            chatCompletionRequest: OAIChatCompletionRequest(
                model: GPTModels.GPT4o.rawValue,
                stream: true,
                messages: messages),
            function: "generate_code")
        
        // Reset streamingFunction
        await MainActor.run {
            streamingFunction = ""
        }
        
        // Stream chat and set chatGenerator
        do {
            let chatGenerator = ChatGenerator()
            await MainActor.run {
                self.chatGenerator = chatGenerator
            }
            try await chatGenerator.streamChat(
                getChatRequest: getChatRequest,
                stream: { getChatResponse in
                    if let responseMessageDelta = getChatResponse.body.oaiResponse.choices[safe: 0]?.delta.toolCalls?[safe: 0]?.function.arguments {
                        streamingFunction += responseMessageDelta
                    }
                })
        } catch {
            // TODO: Handle Errors
            print("Error streaming chat in DiscussionView... \(error)")
        }
        
        // Ensure unwrap transform streamingFunction string to data
        guard let streamingFunctionData = streamingFunction.data(using: .utf8) else {
            // TODO: Handle Errors
            print("Could not unwrap streamingFunction as data in DiscussionGenerator!")
            return
        }
        
        // Parse GenerateCodeFC
        let generateCodeFC: GenerateCodeFC
        do {
            generateCodeFC = try JSONDecoder().decode(GenerateCodeFC.self, from: streamingFunctionData)
        } catch {
            // TODO: Handle Errors
            print("Error decoding generateCodeFC in DiscussionView... \(error)")
            return
        }
        
        // Create chat and add to discussion chats
        let chat = Chat(
            role: .assistant,
            message: generateCodeFC)
        
        discussion.chats.append(chat)
        
//        // Bulid functionCallRequest
//        let functionCallRequest = FunctionCallRequest(
//            authToken: authToken,
//            openAIKey: openAIKey,
//            model: .GPT4o,
//            messages: messages)
//        
//        // Get oaiCompletionResponse and set generateCodeFCAICodingHelperHTTPSConnector
//        let oaiCompletionResponse: OAICompletionResponse
//        do {
//            let generateCodeFCAICodingHelperHTTPSConnector = AICodingHelperHTTPSConnector()
//            await MainActor.run {
//                self.generateCodeFCAICodingHelperHTTPSConnector = generateCodeFCAICodingHelperHTTPSConnector
//            }
//            oaiCompletionResponse = try await generateCodeFCAICodingHelperHTTPSConnector.functionCallRequest(
//                endpoint: Constants.Networking.HTTPS.Endpoints.generateCode,
//                request: functionCallRequest)
//        } catch {
//            // TODO: Handle Errors
//            print("Error getting function call response in DiscussionView... \(error)")
//            return
//        }
//        
//        // Ensure unwrap tool and toolData from oaiCompletionResponse
//        guard let tool = oaiCompletionResponse.body.response.choices[safe: 0]?.message.toolCalls[safe: 0]?.function.arguments,
//              let toolData = tool.data(using: .utf8) else {
//            // TODO: Handle Errors
//            print("Could not unwrap tool or toolData in DiscussionView!")
//            return
//        }
//        
//        // Parse GenerateCodeFC
//        let generateCodeFC: GenerateCodeFC
//        do {
//            generateCodeFC = try JSONDecoder().decode(GenerateCodeFC.self, from: toolData)
//        } catch {
//            // TODO: Handle Errors
//            print("Error decoding generateCodeFC in DiscussionView... \(error)")
//            return
//        }
//        
//        // Create chat and add to discussion chats
//        let chat = Chat(
//            role: .assistant,
//            message: generateCodeFC)
//        
//        discussion.chats.append(chat)
    }
    
}
