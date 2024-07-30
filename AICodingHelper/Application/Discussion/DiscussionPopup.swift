//
//  DiscussionPopup.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/25/24.
//

import SwiftUI

struct DiscussionPopup: ViewModifier {
    
    @Binding var isPresented: Bool
    @Binding var rootFilepath: String
    @ObservedObject var discussionGenerator: DiscussionGenerator
    var onResetDiscussion: () -> Void
    
    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented) {
                VStack {
                    DiscussionView(
                        rootFilepath: $rootFilepath,
                        discussionGenerator: discussionGenerator,
                        onResetDiscussion: onResetDiscussion,
                        content: {
                            
                        })
                    
                    HStack {
                        Spacer()
                        
                        Button("Close") {
                            isPresented = false
                        }
                    }
                }
                .padding()
                .frame(idealWidth: 1050.0, idealHeight: 800.0)
            }
    }
    
}


extension View {
    
    func discussionPopup(isPresented: Binding<Bool>, rootFilepath: Binding<String>, discussionGenerator: DiscussionGenerator, onResetDiscussion: @escaping () -> Void) -> some View {
        return self
            .sheet(isPresented: isPresented) {
                VStack {
                    DiscussionView(
                        rootFilepath: rootFilepath,
                        discussionGenerator: discussionGenerator,
                        onResetDiscussion: onResetDiscussion,
                        content: {
                            
                        })
                    
                    HStack {
                        Spacer()
                        
                        Button("Close") {
                            isPresented.wrappedValue = false
                        }
                    }
                }
                .padding()
                .frame(idealWidth: 1050.0, idealHeight: 800.0)
            }
//        if let discussion = discussion.wrappedValue {
//            return self
//                .modifier(DiscussionPopup(
//                    isPresented: isPresented,
//                    rootFilepath: rootFilepath,
//                    currentDiscussion: discussion,
//                    isLoading: isLoading,
//                    generateOnAppear: generateOnAppear,
//                    onResetDiscussion: onResetDiscussion))
//        }
    }
    
}


#Preview {
    
    ZStack {
        
    }
    .modifier(
        DiscussionPopup(
            isPresented: .constant(true),
            rootFilepath: .constant("~/Downloads/test_dir"),
            discussionGenerator: DiscussionGenerator(discussion: Discussion(chats: [])),
            onResetDiscussion: {
                
            })
    )
    
}
