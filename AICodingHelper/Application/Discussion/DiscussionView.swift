//
//  DiscussionView.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/20/24.
//

import SwiftUI

struct DiscussionView<Content: View>: View {
    
    var title: String = "Discuss Changes"
    @Binding var rootFilepath: String
//    @Binding var selectedFilepaths: [String]
    @ObservedObject var discussionGenerator: DiscussionGenerator
//    @State var generateOnAppear: Bool
    var onResetDiscussion: () -> Void
    @ViewBuilder var content: Content
    
//    @ObservedObject var discussion: Discussion
//    @ObservedObject var tabsViewModel: TabsViewModel
//    @Binding var isLoading: Bool
    
    @EnvironmentObject private var activeSubscriptionUpdater: ActiveSubscriptionUpdater
    
    @FocusState private var focused
    
//    @State private var newInput: String = ""
//    @State private var newFilepaths: [String] = []
    
//    @State private var chatGenerator: ChatGenerator?
//    @State private var generateCodeFCAICodingHelperHTTPSConnector: AICodingHelperHTTPSConnector?
    
//    @State private var streamingChat: String = ""
    
    @State private var isCancelling: Bool = false
    
    @State private var isShowingDirectoryImporter: Bool = false
    
    @State private var commandReturnEventMonitorCreated: Bool = false
    
    @State private var directoryImporterNewFilepath: String = ""
    
    
    private var canCancelGeneration: Binding<Bool> {
        Binding(
            get: {
                // Can cancel generation if neither chatGenerator and generateCodeFCAICodingHelperHTTPSConnector are nil
                discussionGenerator.chatGenerator != nil || discussionGenerator.generateCodeFCAICodingHelperHTTPSConnector != nil
            },
            set: { value in
                // No actions
            })
    }
    
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.title)
                .bold()
            
            content
            
            ScrollView {
                LazyVStack(alignment: .trailing) {
                    if discussionGenerator.isLoading {
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
                                    discussionGenerator.generateCodeFCAICodingHelperHTTPSConnector?.cancel()
                                    
                                    // Cancel chatGenerator
                                    do {
                                        try await discussionGenerator.chatGenerator?.cancel()
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
                    if !discussionGenerator.streamingChat.isEmpty {
                        ChatView(
                            rootFilepath: $rootFilepath,
                            chat: Chat(
                                role: .assistant,
                                message: discussionGenerator.streamingChat),
                            onDelete: {
                                
                            })
                        .rotationEffect(.degrees(180))
                    }
                    ForEach(discussionGenerator.discussion.chats.reversed()) { chat in
                        ChatViewContainer(
                            rootFilepath: $rootFilepath,
                            chat: chat,
                            onDelete: {
                                discussionGenerator.discussion.chats.removeAll(where: {$0 === chat})
                            })
                        .rotationEffect(.degrees(180))
                        .padding(.vertical, 8)
                    }
                }
            }
            .scrollIndicators(.never)
            .rotationEffect(.degrees(180))
            
            Spacer()
            
            ChatInputView(
                newInput: $discussionGenerator.newInput,
                newFilepaths: $discussionGenerator.newFilepaths,
                doBuildCodeGeneration: {
                    discussionGenerator.doBuildCodeGeneration(
                        activeSubscriptionUpdater: activeSubscriptionUpdater,
                        rootFilepath: rootFilepath)
                },
                doChatGeneration: {
                    discussionGenerator.doChatGeneration(activeSubscriptionUpdater: activeSubscriptionUpdater)
                })
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
                        discussionGenerator.doChatGeneration(activeSubscriptionUpdater: activeSubscriptionUpdater)
                    }
                    
                    return event
                }
                
                commandReturnEventMonitorCreated = true
            }
        }
//        .onAppear {
//            if generateOnAppear {
//                doBuildCodeGeneration()
//            }
//        }
        .onChange(of: directoryImporterNewFilepath) { newValue in
            // Append newValue to newFilepaths if it is not empty and newFilepaths does not contain it
            if !newValue.isEmpty,
               !discussionGenerator.newFilepaths.contains(where: {$0 == newValue}) {
                discussionGenerator.newFilepaths.append(newValue)
            }
            
            // Reset directoryImporterNewFilepath
            directoryImporterNewFilepath = ""
        }
    }
    
}

#Preview {
    
    DiscussionView(
//        selectedFilepaths: .constant([]),,
        rootFilepath: .constant(""),
        discussionGenerator: DiscussionGenerator(
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
            )),
        onResetDiscussion: {
            
        },
        content: {
            
        }
    )
    .padding()
    .background(Color.foreground)
    .frame(width: 550.0, height: 500.0)
    .environmentObject(CodeEditorSettingsViewModel())
    
}
