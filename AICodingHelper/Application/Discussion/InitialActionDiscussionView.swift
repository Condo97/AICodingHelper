//
//  InitialActionDiscussionView.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/29/24.
//

import SwiftUI

struct InitialActionDiscussionView: View {
    
    @Binding var rootFilepath: String
    @Binding var selectedFilepaths: [String]
    @ObservedObject var discussionGenerator: DiscussionGenerator
    @ObservedObject var tabsViewModel: TabsViewModel
    var onResetDiscussion: () -> Void
    
    @EnvironmentObject private var activeSubscriptionUpdater: ActiveSubscriptionUpdater
    
    var body: some View {
        VStack {
            DiscussionView(
                title: discussionGenerator.discussion.chats.count == 0 ? "AI Task" : "Discuss Changes",
                rootFilepath: $rootFilepath,
                discussionGenerator: discussionGenerator,
                onResetDiscussion: onResetDiscussion,
                content: {
                    if discussionGenerator.discussion.chats.count == 0 {
                        CodeGeneratorControlsView(
                            rootFilepath: $rootFilepath,
                            selectedFilepaths: $selectedFilepaths,
                            tabsViewModel: tabsViewModel,
                            onSubmit: { actionType, generateOptions in
                                Task {
                                    // Create instructions from action aiPrompt and userInput
                                    let instructions = actionType.aiPrompt + (discussionGenerator.newInput.isEmpty ? "" : "\n" + discussionGenerator.newInput)
                                    
                                    // Get referenceFilepaths from selectedFilepaths or if empty array with contents of rootFilepath
                                    let referenceFilepaths: [String] = selectedFilepaths.isEmpty ? try FileManager.default.contentsOfDirectory(atPath: rootFilepath) : selectedFilepaths
                                    
                                    // Get relativeReferenceFilepaths from referenceFilepaths
                                    let relativeReferenceFilepaths: [String] = referenceFilepaths.map({$0.replacingOccurrences(of: rootFilepath, with: "")})
                                    
                                    // Create Chat and append to Discussion
                                    let chat = Chat(
                                        role: .user,
                                        message: instructions,
                                        referenceFilepaths: relativeReferenceFilepaths)
                                    
                                    // Append generate code FC to discussion chats
                                    discussionGenerator.discussion.chats.append(chat)
                                    
                                    // Generate generate code FC chat
                                    await discussionGenerator.doBuildCodeGeneration(
                                        activeSubscriptionUpdater: activeSubscriptionUpdater,
                                        rootFilepath: rootFilepath)
                                }
                            })
                    }
                })
            .frame(width: discussionGenerator.discussion.chats.count == 0 ? 350.0 : .infinity)
        }
    }
    
}

#Preview {
    
    InitialActionDiscussionView(
        rootFilepath: .constant("~/Downloads/test_dir"),
        selectedFilepaths: .constant([]),
        discussionGenerator: DiscussionGenerator(discussion: Discussion(chats: [])),
        tabsViewModel: TabsViewModel(),
        onResetDiscussion: {
            
        })
        .environmentObject(ActiveSubscriptionUpdater())
    
}
