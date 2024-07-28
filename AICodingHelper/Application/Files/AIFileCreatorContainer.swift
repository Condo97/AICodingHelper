//
//  AIFileCreatorContainer.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/7/24.
//

import SwiftUI

struct AIFileCreatorContainer: View {
    
    @Binding var isPresented: Bool
    @State var rootFilepath: String
    @State var referenceFilepaths: [String] // This is a state because if it is changed it should not propogate to the parent
    @ObservedObject var progressTracker: ProgressTracker
    
    
    private static let generateFileBaseInstructions = "Generate the file"
    private static let fileGeneratorSystemMessage = "You are an AI coding helper service in an IDE so you must format all your responses in code that would be valid in an IDE. Do not include ```LanguageName or ``` to denote code. You only respond with code that is valid in that language. You only respond to the one requested file. All files will be provided in turn, so therefore you will respond to each individually to preserve correct formatting to the IDE since it is looking to receive one file. You may include messages in comments if the langauge supports comments."
    
    
    @EnvironmentObject private var activeSubscriptionUpdater: ActiveSubscriptionUpdater
    @EnvironmentObject private var remainingUpdater: RemainingUpdater
    
    @State private var currentDiscussion: Discussion?
    
    @State private var isLoadingDiscussion: Bool = false
    
    @State private var isShowingDiscussionView: Bool = false
    
    @State private var newFileName: String = ""
    @State private var userPrompt: String = ""
    
    
    var body: some View {
        AIFileCreatorView(
            newFileName: $newFileName,
            referenceFilepaths: $referenceFilepaths,
            userPrompt: $userPrompt,
            onCancel: {
                // Dismiss
                withAnimation {
                    isPresented = false
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
                    
                    // Get instructions from generateFileBaseInstructions + " " + newFileName + "\nProject Language " + userPrompt or blank if empty
                    let instructions = AIFileCreatorContainer.generateFileBaseInstructions + " " + newFileName + (userPrompt.isEmpty ? "" : "\n" + userPrompt)
                    
                    // Create userChat from instructions
                    let userChat = Chat(
                        role: .user,
                        message: instructions)
                    
                    // Create Discussion with userChat and set to currentDiscussion
                    currentDiscussion = Discussion(chats: [userChat])
                    
                    // Set isShowingDiscussionView to true
                    isShowingDiscussionView = true
                }
            })
        .discussionPopup(
            discussion: $currentDiscussion,
            rootFilepath: $rootFilepath,
            isLoading: $isLoadingDiscussion,
            generateOnAppear: true,
            onResetDiscussion: {
                
            })
        .overlay { // TODO: This could be an alert
            if isLoadingDiscussion {
                ZStack {
                    Colors.foreground
                        .opacity(0.4)
                    
                    VStack {
                        Text("Creating File...")
                        
                        ProgressView()
                            .tint(Colors.foregroundText)
                    }
                }
            }
        }
    }
    
}


extension View {
    
    func aiFileCreatorPopup(isPresented: Binding<Bool>, rootFilepath: String, referenceFilepaths: [String]) -> some View {
        self
            .sheet(isPresented: isPresented) {
                AIFileCreatorContainer(
                    isPresented: isPresented,
                    rootFilepath: rootFilepath,
                    referenceFilepaths: referenceFilepaths,
                    progressTracker: ProgressTracker())
            }
    }
    
}


#Preview {
    
    AIFileCreatorContainer(
        isPresented: .constant(true),
        rootFilepath: "~/Downloads/test_dir",
        referenceFilepaths: [],
        progressTracker: ProgressTracker()
    )
    
}
