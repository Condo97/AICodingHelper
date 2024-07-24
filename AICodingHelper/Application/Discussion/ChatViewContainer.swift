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
    
    @State private var isApplied: Bool = false
    
    @State private var isHoveringApplyButton: Bool = false
    
    var body: some View {
        HStack {
            if chat.message is GenerateCodeFC {
                Button(action: {
                    // Apply changes
                    if let message = chat.message as? GenerateCodeFC {
                        for file in message.output_files {
                            let relativeFilepath = file.filepath.replacingOccurrences(of: rootFilepath, with: "")
                            let fullFilepath = URL(fileURLWithPath: rootFilepath).appendingPathComponent(relativeFilepath, conformingTo: .text).path
                            
                            FileCreator.createFile(
                                filepath: fullFilepath,
                                content: file.content)
                        }
                    }
                    
                    // Set isApplied to true
                    isApplied = true
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8.0)
                            .stroke(Color.background)
                            .opacity(isHoveringApplyButton ? 1.0 : 0.0)
                        
                        VStack {
                            Image(systemName: isApplied ? "checkmark" : "chevron.left.2")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20.0)
                            Text(isApplied ? "Applied" : "Apply")
                                .font(.subheadline)
                        }
                        .foregroundStyle(isApplied ? Color(.systemGreen) : Color.foregroundText)
                    }
                    .frame(width: 50.0)
                    .frame(maxHeight: .infinity)
                    .onHover { hovering in
                        withAnimation(.bouncy(duration: 0.5)) {
                            isHoveringApplyButton = hovering
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            ChatView(
                chat: chat,
                onDelete: onDelete)
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
