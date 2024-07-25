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
    @ObservedObject var currentDiscussion: Discussion
    @Binding var isLoading: Bool
    @State var generateOnAppear: Bool
    var onResetDiscussion: () -> Void
    
    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented) {
                VStack {
                    DiscussionView(
                        rootFilepath: $rootFilepath,
                        discussion: currentDiscussion,
                        isLoading: $isLoading,
                        generateOnAppear: generateOnAppear,
                        onResetDiscussion: {
                            
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
    
    func discussionPopup(discussion: Binding<Discussion?>, rootFilepath: Binding<String>, isLoading: Binding<Bool>, generateOnAppear: Bool, onResetDiscussion: @escaping () -> Void) -> some View {
        var isPresented: Binding<Bool> {
            Binding(
                get: {
                    // Presented if discussion wrappedValue is not nil
                    discussion.wrappedValue != nil
                },
                set: { value in
                    // Set discussion to nil if value is false
                    if !value {
                        discussion.wrappedValue = nil
                    }
                })
        }
        
        return self
            .sheet(isPresented: isPresented) {
                if let discussion = discussion.wrappedValue {
                    VStack {
                    DiscussionView(
                        rootFilepath: rootFilepath,
                        discussion: discussion,
                        isLoading: isLoading,
                        generateOnAppear: generateOnAppear,
                        onResetDiscussion: onResetDiscussion)
                        
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
            currentDiscussion: Discussion(chats: []),
            isLoading: .constant(false),
            generateOnAppear: false,
            onResetDiscussion: {
                
            })
    )
    
}
