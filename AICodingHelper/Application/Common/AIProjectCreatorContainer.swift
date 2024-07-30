//
//  AIProjectCreatorContainer.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/8/24.
//

import SwiftUI

struct AIProjectCreatorContainer: View {
    
    @Binding var isPresented: Bool
    @Binding var rootFilepath: String
    
    // Basically the goal is to create a code generation plan to create a project, we will need to generate a plan and then generate the project so there may need to be a popup confirming how many tokens it will be, or maybe it can just be on that window like the submit button could be diabled and be changed with a different word like it could say "Next...", which will then disable the button and either an alert will pop up confirming the generation or the next button will become "Generate" and the token count will appear to the left but idk I like the first one better lol
    
    @EnvironmentObject private var activeSubscriptionUpdater: ActiveSubscriptionUpdater
    @EnvironmentObject private var remainingUpdater: RemainingUpdater
    
    private static let generateProjectInitialChatBaseInstructions: String = "Generate a project per the user's prompt."
    private static let createProjectSystemMessage: String = "You are an AI coding helper service in an IDE so you must format all your responses in code that would be valid in an IDE. Do not include ```LanguageName or ``` to denote code. You only respond with code that is valid in that language. You only respond to the one requested file. All files will be provided in turn, so therefore you will respond to each individually to preserve correct formatting to the IDE since it is looking to receive one file. You may include messages in comments if the langauge supports comments."// "You are creating a project in code for the specified language formatted for an IDE."
    private static let additionalTokensForEstimationPerFile: Int = Constants.Additional.additionalTokensForEstimationPerFile
    
    @StateObject private var discussionGenerator: DiscussionGenerator = DiscussionGenerator(discussion: Discussion(chats: []))
    
    @State private var referenceFilepaths: [String] = []
    @State private var language: String = ""
    @State private var userPrompt: String = ""
    
    @State private var isLoadingDiscussion: Bool = false
    
    @State private var isShowingDiscussionView: Bool = false
    
    @State private var alertShowingConfirmCodeGeneration: Bool = false
    
    
    var body: some View {
        AIProjectCreatorView(
            baseProjectFilepath: $rootFilepath,
            referenceFilepaths: $referenceFilepaths,
            language: $language,
            userPrompt: $userPrompt,
            onCancel: {
                // Dismiss
                DispatchQueue.main.async {
                    withAnimation {
                        isPresented = false
                    }
                }
            },
            onSubmit: {
                Task {
                    // Defer setting isLoadingDiscussion to false
                    defer {
                        DispatchQueue.main.async {
                            self.isLoadingDiscussion = false
                        }
                    }
                    
                    // Set isLoadingPlanProject to true
                    await MainActor.run {
                        isLoadingDiscussion = true
                    }
                    
                    // Ensure authToken
                    let authToken: String
                    do {
                        authToken = try await AuthHelper.ensure()
                    } catch {
                        // TODO: Handle Errors
                        print("Error ensuring authToken in AIProjectCreatorContainer... \(error)")
                        return
                    }
                    
                    // Get openAIKey
                    let openAIKey = activeSubscriptionUpdater.openAIKeyIsValid ? activeSubscriptionUpdater.openAIKey : nil
                    
                    // Get instructions from generatePlanBaseInstructions + "\nProject Language " + language + "\n" + userPrompt or blank if empty
                    let instructions = AIProjectCreatorContainer.generateProjectInitialChatBaseInstructions + "\nProject Language " + language + (userPrompt.isEmpty ? "" : "\n" + userPrompt)
                    
                    // Create userChat from instructions
                    let userChat = Chat(
                        role: .user,
                        message: instructions)
                    
                    // Append currentDiscussion to discussionGenerator discussion chats
                    discussionGenerator.discussion.chats.append(userChat)
                    
                    // Set isShowingDiscussionView to true
                    isShowingDiscussionView = true
                }
            })
        .disabled(isLoadingDiscussion)
        .discussionPopup(
            isPresented: $isShowingDiscussionView,
            rootFilepath: $rootFilepath,
            discussionGenerator: discussionGenerator,
            onResetDiscussion: {
                
            })
//        .sheet(isPresented: $isShowingDiscussionView) {
//            if let currentDiscussion = currentDiscussion {
//                VStack {
//                    DiscussionView(
//                        rootFilepath: $rootFilepath,
//                        discussion: currentDiscussion,
//                        isLoading: $isLoadingDiscussion,
//                        generateOnAppear: true,
//                        onResetDiscussion: {
//                            
//                        })
//                    
//                    HStack {
//                        Spacer()
//                        
//                        Button("Close") {
//                            isShowingDiscussionView = false
//                        }
//                    }
//                }
//                .padding()
//                .frame(idealWidth: 1050.0, idealHeight: 800.0)
//            }
//        }
        .overlay {
            if isLoadingDiscussion {
                ZStack {
                    Colors.foreground
                        .opacity(0.4)
                    
                    VStack {
                        Text("Loading...")
                        
                        ProgressView()
                            .tint(Colors.foregroundText)
                    }
                }
            }
        }
    }
    
}

#Preview {
    
    AIProjectCreatorContainer(
        isPresented: .constant(true),
        rootFilepath: .constant("~/Downloads/test_dir")
    )
    
}
