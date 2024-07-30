//
//  CodeGeneratorContainer.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/20/24.
//

import SwiftUI

struct CodeGeneratorContainer: View {
    
//    @Binding var scope: Scope
    @Binding var rootFilepath: String
//    @ObservedObject var progressTracker: ProgressTracker
    @ObservedObject var tabsViewModel: TabsViewModel
    @Binding var fileBrowserSelectedFilepaths: [String]
    @Binding var isLoading: Bool
    
    @Environment(\.undoManager) private var undoManager
    
    @EnvironmentObject private var activeSubscriptionUpdater: ActiveSubscriptionUpdater
    @EnvironmentObject private var remainingUpdater: RemainingUpdater
    
    @StateObject private var discussionGenerator: DiscussionGenerator = DiscussionGenerator(discussion: Discussion(chats: []))
    
    @State private var alertShowingInvalidOpenAIKey: Bool = false
    
    var body: some View {
        ZStack {
            InitialActionDiscussionView(
                rootFilepath: $rootFilepath,
                selectedFilepaths: $fileBrowserSelectedFilepaths,
                discussionGenerator: discussionGenerator,
                tabsViewModel: tabsViewModel,
                onResetDiscussion: {
                    discussionGenerator.discussion = Discussion(chats: [])
                })
            .padding()
            .frame(idealWidth: 350.0)
        }
        .alert("Invalid OpenAI Key", isPresented: $alertShowingInvalidOpenAIKey, actions: {
            Button("Close") {
                
            }
        }, message: {
            Text("Your Open AI API Key is invalid and your plan will be used until it is updated. If you believe this is an error please report it!")
        })
//        .overlay {
//            if let currentDiscussion = currentDiscussion {
//                DiscussionView(
//                    rootFilepath: $rootFilepath,
//                    discussion: currentDiscussion,
//                    isLoading: $isLoadingDiscussion)
//                .padding()
//            }
//        }
    }
    
    
//    func generateAndAppendGenerateCodeFCToDiscussion(instructions: String, referenceFilepaths: [String], copyCurrentFilesToTempFiles: Bool) async {
////        // Ensure is not loading otherwise return
////        guard !isLoading else {
////            // TODO: Handle Errors
////            return
////        }
////        
////        // Defer setting isLoading to false
////        defer {
////            DispatchQueue.main.async {
////                self.isLoading = false
////            }
////        }
////        
////        // Set isLoading to true
////        await MainActor.run {
////            isLoading = true
////        }
//        
//        // Remove baseFilepath from referenceFilepaths TODO: Should this be done here?
//        let relativeReferenceFilepaths: [String] = referenceFilepaths.map({$0.replacingOccurrences(of: rootFilepath, with: "")})
//        
//        // If discussion is nil set to new discussion
//        if currentDiscussion == nil {
//            currentDiscussion = Discussion(chats: [])
//        }
//        
//        // Append user chat to currentDiscussion
//        currentDiscussion?.chats.append(
//            Chat(
//                role: .user,
//                message: instructions,
//                referenceFilepaths: relativeReferenceFilepaths))
//    }
//        
//        // Ensure authToken
//        let authToken: String
//        do {
//            authToken = try await AuthHelper.ensure()
//        } catch {
//            // TODO: Handle Errors
//            print("Error ensuring authToken in MainView... \(error)")
//            return
//        }
//        
//        // Get openAIKey
//        let openAIKey = activeSubscriptionUpdater.openAIKeyIsValid ? activeSubscriptionUpdater.openAIKey : nil
//        
//        // Generate and append to discussion
//        do {
//            guard let generateCodeFC = try await CodeGenerator().generateCode(
//                authToken: authToken,
//                openAIKey: openAIKey,
//                model: .GPT4o,
//                instructions: instructions,
//                rootFilepath: rootFilepath,
//                selectedFilepaths: referenceFilepaths,
//                copyCurrentFilesToTempFiles: copyCurrentFilesToTempFiles) else {
//                // TODO: Handle Errors
//                print("Could not unwrap generateCodeFC in CodeGeneratorControlsContainer!")
//                return
//            }
//            
//            currentDiscussion?.chats.append(
//                Chat(
//                    role: .assistant,
//                    message: generateCodeFC))
////                        progressTracker: progressTracker)
//        } catch GenerationError.invalidOpenAIKey {
//            // If received invalidOpenAIKey set openAIKeyIsValid to false and show alert
//            activeSubscriptionUpdater.openAIKeyIsValid = false
//            alertShowingInvalidOpenAIKey = true
//        } catch {
//            // TODO: Handle Errors
//            print("Error generating and refactoring code in CodeGeneratorController... \(error)")
//        }
//    }
    
}

#Preview {
    
    CodeGeneratorContainer(
        rootFilepath: .constant("~/Downloads/test_dir"),
        tabsViewModel: TabsViewModel(),
        fileBrowserSelectedFilepaths: .constant([]),
        isLoading: .constant(true)
    )
    
}
