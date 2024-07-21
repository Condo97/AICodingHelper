//
//  DiscussionView.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/20/24.
//

import SwiftUI

struct DiscussionView: View {
    
    @Binding var rootFilepath: String
    @ObservedObject var discussion: Discussion
    @Binding var isLoading: Bool
    
    @EnvironmentObject private var activeSubscriptionUpdater: ActiveSubscriptionUpdater
    
    @FocusState private var focused
    
    @State private var newInput: String = ""
    @State private var newFilepaths: [String] = []
    
    @State private var streamingChat: String = ""
    
    @State private var isShowingDirectoryImporter: Bool = false
    
    @State private var directoryImporterNewFilepath: String = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Discuss Changes")
                .font(.title)
                .bold()
            
            ScrollView {
                VStack(alignment: .leading) {
                    if !streamingChat.isEmpty {
                        ChatView(
                            chat: Chat(
                                role: .assistant,
                                message: streamingChat),
                            onDelete: {
                                
                            })
                        .rotationEffect(.degrees(180))
                    }
                    ForEach(discussion.chats.reversed()) { chat in
                        ChatViewContainer(
                            rootFilepath: $rootFilepath,
                            chat: chat,
                            onDelete: {
                                discussion.chats.removeAll(where: {$0 === chat})
                            })
                        .rotationEffect(.degrees(180))
                        .padding(.vertical, 8)
                    }
                }
            }
            .scrollIndicators(.never)
            .rotationEffect(.degrees(180))
            
            Spacer()
            
            HStack(alignment: .bottom) {
                VStack(alignment: .leading) {
                    Text("Message")
                        .font(.subheadline)
                        .bold()
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $newInput)
                            .focused($focused)
                            .frame(height: 80.0)
                        
                        Text("Enter Message...")
                            .opacity(focused ? 0.0 : 0.4)
                            .onTapGesture {
                                focused = true
                            }
                    }
                    
                    Text("Files")
                        .font(.subheadline)
                        .bold()
                    
                    ForEach(newFilepaths, id: \.self) { filepath in
                        Text(filepath)
                            .font(.system(size: 9.0))
                            .opacity(0.6)
                    }
                    
                    Button("Add File") {
                        isShowingDirectoryImporter = true
                    }
                }
                
                VStack(alignment: .leading) {
                    Button("Build Code") {
                        // Create chat with newInput and append to discussion chats
                        discussion.chats.append(
                            Chat(
                                role: .user,
                                message: newInput,
                                referenceFilepaths: newFilepaths.isEmpty ? nil : newFilepaths)
                        )
                        
                        // Reset newInput and newFilepaths
                        newInput = ""
                        newFilepaths = []
                        
                        // Generate geneate code FC chat
                        Task {
                            await generateGenerateCodeFCChat()
                        }
                    }
                    
                    Button("Chat \(Image(systemName: "return"))") {
                        // Create chat with newInput and append to discussion chats
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
                            await generateStringChat()
                        }
                    }
                    .keyboardShortcut(.defaultAction)
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 4.0)
                .stroke(focused ? Colors.element : Colors.background, lineWidth: focused ? 2.0 : 1.0))
        }
        .grantedPermissionsDirectoryImporter(
            isPresented: $isShowingDirectoryImporter,
            filepath: $directoryImporterNewFilepath,
            canChooseDirectories: true,
            canChooseFiles: true)
        .onChange(of: directoryImporterNewFilepath) { newValue in
            // Append newValue to newFilepaths if it is not empty and newFilepaths does not contain it
            if !newValue.isEmpty,
               !newFilepaths.contains(where: {$0 == newValue}) {
                newFilepaths.append(newValue)
            }
            
            // Reset directoryImporterNewFilepath
            directoryImporterNewFilepath = ""
        }
    }
    
    
    func generateStringChat() async {
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
                if let message = $0.message as? GenerateCodeFC,
                   let messageString = String(data: try JSONEncoder().encode(message), encoding: .utf8) {
                    return OAIChatCompletionRequestMessage(
                        role: $0.role,
                        content: [
                            .text(OAIChatCompletionRequestMessageContentText(text: messageString))
                        ])
                }
                
                if let message = $0.message as? String {
                    return OAIChatCompletionRequestMessage(
                        role: $0.role,
                        content: [
                            .text(OAIChatCompletionRequestMessageContentText(text: message))
                        ])
                }
                
                return nil
            })
        } catch {
            // TODO: Handle Errors
            print("Error transforming discussion chats to messages in DiscussionView... \(error)")
            return
        }
        
        // Build getChatRequest
        let getChatRequest = GetChatRequest(
            authToken: authToken,
            chatCompletionRequest: OAIChatCompletionRequest(
                model: GPTModels.GPT4o.rawValue,
                stream: true,
                messages: messages))
        
        // Reset streamingChat
        await MainActor.run {
            streamingChat = ""
        }
        
        // Stream chat
        do {
            try await ChatGenerator.streamChat(
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
    
    func generateGenerateCodeFCChat() async {
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
        let messages: [OAIChatCompletionRequestMessage] = discussion.chats.compactMap({
            guard let message = $0.message as? String else {
                return nil
            }
            
            return OAIChatCompletionRequestMessage(
                role: $0.role,
                content: [
                    .text(OAIChatCompletionRequestMessageContentText(text: message))
                ])
        })
        
        // Get openAIKey
        let openAIKey = activeSubscriptionUpdater.openAIKeyIsValid ? activeSubscriptionUpdater.openAIKey : nil
        
        // Bulid functionCallRequest
        let functionCallRequest = FunctionCallRequest(
            authToken: authToken,
            openAIKey: openAIKey,
            model: .GPT4o,
            messages: messages)
        
        // Get oaiCompletionResponse
        let oaiCompletionResponse: OAICompletionResponse
        do {
            oaiCompletionResponse = try await AICodingHelperHTTPSConnector.functionCallRequest(
                endpoint: Constants.Networking.HTTPS.Endpoints.generateCode,
                request: functionCallRequest)
        } catch {
            // TODO: Handle Errors
            print("Error getting function call response in DiscussionView... \(error)")
            return
        }
        
        // Ensure unwrap tool and toolData from oaiCompletionResponse
        guard let tool = oaiCompletionResponse.body.response.choices[safe: 0]?.message.toolCalls[safe: 0]?.function.arguments,
              let toolData = tool.data(using: .utf8) else {
            // TODO: Handle Errors
            print("Could not unwrap tool or toolData in DiscussionView!")
            return
        }
        
        // Parse GenerateCodeFC
        let generateCodeFC: GenerateCodeFC
        do {
            generateCodeFC = try JSONDecoder().decode(GenerateCodeFC.self, from: toolData)
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
    }
    
}

#Preview {
    
    DiscussionView(
        rootFilepath: .constant("~/Downloads/test_dir"),
        discussion: Discussion(
            chats: [
                Chat(
                    role: .user,
                    message: "Hi can u make it so that my code works thank you!"),
                Chat(
                    role: .assistant,
                    message: GenerateCodeFC(
                        files: [GenerateCodeFC.File(
                            filepath: "Test/Filepath",
                        	content: "Test File Content")])
                ),
                Chat(
                    role: .user,
                    message: "Okay now do some more stuff"),
                Chat(
                    role: .assistant,
                    message: GenerateCodeFC(
                        files: [
                            GenerateCodeFC.File(
                                filepath: "~/Downloads/test_dir/file.txt",
                                content: "This is the content of the file"),
                            GenerateCodeFC.File(
                                filepath: "~/Downloads/test_dir/anotherfile.txt",
                                content: "This is the content of the second file")
                        ]))
            ]
        ),
        isLoading: .constant(false)
    )
    .padding()
    .background(Color.foreground)
    .frame(width: 550.0, height: 500.0)
    .environmentObject(ActiveSubscriptionUpdater())
    
}
