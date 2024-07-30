//
//  ChatViewContainer.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/21/24.
//

import SwiftUI

struct ChatViewContainer: View {
    
    @Binding var rootFilepath: String
    @ObservedObject var chat: Chat
    var onDelete: () -> Void
    
    @Environment(\.undoManager) private var undoManager
    
    @State private var isApplied: Bool = false
    
    @State private var isHoveringApplyButton: Bool = false
    
    var body: some View {
        VStack {
            // Chat View
            ChatView(
                rootFilepath: $rootFilepath,
                chat: chat,
                onDelete: onDelete)
            
            // Apply All Button
            if let message = chat.message as? GenerateCodeFC,
               message.output_files.count > 1 {
                Button(action: {
                    // Apply changes
                    if let message = chat.message as? GenerateCodeFC {
                        GenerateCodeFCApplier.apply(message, rootFilepath: rootFilepath)
                    }
                    
                    // Set isApplied to true
                    isApplied = true
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8.0)
                            .stroke(Color.background)
                            .opacity(isHoveringApplyButton ? 1.0 : 0.0)
                        
                        HStack {
                            Image(systemName: isApplied ? "checkmark" : "chevron.left.2")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20.0)
                            Text(isApplied ? "Applied" : "Apply All")
                                .font(.subheadline)
                            Spacer()
                        }
                        .padding()
                        .foregroundStyle(isApplied ? Color(.systemGreen) : Color.foregroundText)
                    }
//                    .frame(width: 50.0)
//                    .frame(maxHeight: .infinity)
                    .onHover { hovering in
                        withAnimation(.bouncy(duration: 0.5)) {
                            isHoveringApplyButton = hovering
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
}

#Preview {
    ChatViewContainer(
        rootFilepath: .constant("~/Downloads/test_dir"),
        chat: Chat(
            role: .user,
            message: GenerateCodeFC(
                output_files: [
                    GenerateCodeFC.File(
                        filepath: "~/Downloads/test_dir",
                        content: "This is the content for the file.")
                ])),
        onDelete: {
            
        })
    .environmentObject(CodeEditorSettingsViewModel())
}
