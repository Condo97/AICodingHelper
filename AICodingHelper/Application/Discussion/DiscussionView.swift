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
    @State var generateOnAppear: Bool
    var onResetDiscussion: () -> Void
    
    @EnvironmentObject private var activeSubscriptionUpdater: ActiveSubscriptionUpdater
    
    @FocusState private var focused
    
    @State private var newInput: String = ""
    @State private var newFilepaths: [String] = []
    
    @State private var chatGenerator: ChatGenerator?
    @State private var generateCodeFCAICodingHelperHTTPSConnector: AICodingHelperHTTPSConnector?
    
    @State private var streamingChat: String = ""
    
    @State private var isCancelling: Bool = false
    
    @State private var isShowingDirectoryImporter: Bool = false
    
    @State private var commandReturnEventMonitorCreated: Bool = false
    
    @State private var directoryImporterNewFilepath: String = ""
    
    
    private var canCancelGeneration: Binding<Bool> {
        Binding(
            get: {
                // Can cancel generation if neither chatGenerator and generateCodeFCAICodingHelperHTTPSConnector are nil
                chatGenerator != nil || generateCodeFCAICodingHelperHTTPSConnector != nil
            },
            set: { value in
                // No actions
            })
    }
    
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Discuss Changes")
                .font(.title)
                .bold()
            
            ScrollView {
                LazyVStack(alignment: .trailing) {
                    if isLoading {
                        LoadingChatView(
                            canCancel: canCancelGeneration,
                            stopLoading: {
                                Task {
                                    // Defer setting isCancelling to false
                                    defer {
                                        DispatchQueue.main.async {
                                            self.isCancelling = false
                                        }
                                    }
                                    
                                    // Set isCancelling to true
                                    await MainActor.run {
                                        isCancelling = true
                                    }
                                    
                                    // Cancel generateCodeFCAICodingHelperHTTPSConnector this one first since it is not async even though I guess it doesn't matter
                                    generateCodeFCAICodingHelperHTTPSConnector?.cancel()
                                    
                                    // Cancel chatGenerator
                                    do {
                                        try await chatGenerator?.cancel()
                                    } catch {
                                        // TODO: Handle Errors
                                        print("Error cancelling chatGenerator in DiscussionView... \(error)")
                                        return
                                    }
                                }
                            })
                            .padding(.leading, 4)
                            .rotationEffect(.degrees(180))
                    }
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
            
            VStack {
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $newInput)
                        .scrollContentBackground(.hidden)
                        .focused($focused)
                        .frame(height: 80.0)
                    
                    Text("Enter Message...")
                        .opacity(focused ? 0.0 : 0.4)
                        .onTapGesture {
                            focused = true
                        }
                }
                
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Files")
                                .font(.subheadline)
                                .bold()
                            
                            Button("\(Image(systemName: "plus"))") {
                                isShowingDirectoryImporter = true
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.top, 2)
                        
                        VStack(alignment: .leading) {
                            ForEach(newFilepaths, id: \.self) { filepath in
                                Text(filepath)
                                    .lineLimit(1)
                                    .truncationMode(.head)
                                    .font(.system(size: 9.0))
                                    .opacity(0.6)
                            }
                            
                            Text("Drag Files Here")
                                .font(.subheadline)
                                .opacity(isLoading ? 0.2 : 0.6)
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 8.0)
                            .stroke(Color.background.opacity(isLoading ? 0.2 : 0.6), style: StrokeStyle(dash: [5, 3])))
                        .onDrop(of: [.text], isTargeted: nil, perform: { providers in
                            if let provider = providers.first {
                                provider.loadObject(ofClass: NSString.self, completionHandler: { providerReading, error in
                                    if let filepath = providerReading as? String {
                                        if !newFilepaths.contains(where: {$0 == filepath}) {
                                            newFilepaths.append(filepath)
                                        }
                                    }
                                })
                            }
                            
                            return true
                        })
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .leading) {
                        Button("Build Code") {
                            doBuildCodeGeneration()
                        }
                        .help("Build Code - command+shift+return")
                        
                        Button(action: {
                            doChatGeneration()
                        }) {
                            HStack {
                                Text("Chat")
                                HStack(spacing: 0.0) {
                                    Image(systemName: "command")
                                        .imageScale(.small)
                                    Image(systemName: "return")
                                        .imageScale(.small)
                                }
                            }
                        }
                        .help("Chat - command+return")
                        .keyboardShortcut(.defaultAction)
                        .disabled(newInput.isEmpty && newFilepaths.isEmpty)
                    }
                }
                .disabled(isLoading)
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 4.0)
                .stroke(focused ? Colors.element : Colors.background, lineWidth: focused ? 2.0 : 1.0))
        }
        .overlay(alignment: .topTrailing) {
            Button(action: {
                onResetDiscussion()
            }) {
                Image(Constants.ImageName.Icons.broom)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 28.0, height: 28.0)
                    .padding(8)
                    .background(Color.foreground)
                    .clipShape(Circle())
                    .shadow(color: Colors.foregroundText.opacity(0.05), radius: 8.0)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .grantedPermissionsDirectoryImporter(
            isPresented: $isShowingDirectoryImporter,
            filepath: $directoryImporterNewFilepath,
            canChooseDirectories: true,
            canChooseFiles: true)
        .onAppear {
            if !commandReturnEventMonitorCreated {
                NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                    if event.modifierFlags.contains(.command) && event.keyCode == 36 { // Return key code is
                        doChatGeneration()
                    }
                    
                    return event
                }
                
                commandReturnEventMonitorCreated = true
            }
        }
        .onAppear {
            if generateOnAppear {
                doBuildCodeGeneration()
            }
        }
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
    
    
    func doBuildCodeGeneration() {
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
            await generateGenerateCodeFCChat()
        }
    }
    
    func doChatGeneration() {
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
            await generateStringChat()
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
        
        // Bulid functionCallRequest
        let functionCallRequest = FunctionCallRequest(
            authToken: authToken,
            openAIKey: openAIKey,
            model: .GPT4o,
            messages: messages)
        
        // Get oaiCompletionResponse and set generateCodeFCAICodingHelperHTTPSConnector
        let oaiCompletionResponse: OAICompletionResponse
        do {
            let generateCodeFCAICodingHelperHTTPSConnector = AICodingHelperHTTPSConnector()
            await MainActor.run {
                self.generateCodeFCAICodingHelperHTTPSConnector = generateCodeFCAICodingHelperHTTPSConnector
            }
            oaiCompletionResponse = try await generateCodeFCAICodingHelperHTTPSConnector.functionCallRequest(
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
                        output_files: [GenerateCodeFC.File(
                            filepath: "Test/Filepath",
                        	content: "Test File Content")])
                ),
                Chat(
                    role: .user,
                    message: "Okay now do some more stuff"),
                Chat(
                    role: .assistant,
                    message: GenerateCodeFC(
                        output_files: [
                            GenerateCodeFC.File(
                                filepath: "~/Downloads/test_dir/file.txt",
                                content: "This is the content of the file"),
                            GenerateCodeFC.File(
                                filepath: "~/Downloads/test_dir/anotherfile.txt",
                                content: "This is the content of the second file")
                        ]))
            ]
        ),
        isLoading: .constant(false),
        generateOnAppear: true,
        onResetDiscussion: {
            
        }
    )
    .padding()
    .background(Color.foreground)
    .frame(width: 550.0, height: 500.0)
    .environmentObject(ActiveSubscriptionUpdater())
    .environmentObject(CodeEditorSettingsViewModel())
    
}
