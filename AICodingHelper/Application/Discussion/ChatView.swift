//
//  ChatView.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/20/24.
//

import SwiftUI


struct ChatView: View {
    
    @ObservedObject var chat: Chat
    var onDelete: () -> Void
    
    @FocusState private var focused
    
    @State private var isHovering: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(chat.role.rawValue.capitalized)
                    .font(.subheadline)
                    .bold()
                    .padding(.leading, 4)
                
                Spacer()
                
                if isHovering || focused {
                    Button("\(Image(systemName: "xmark.circle"))") {
                        onDelete()
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            
            if let message = chat.message as? GenerateCodeFC {
                var messageBinding: Binding<GenerateCodeFC> {
                    Binding(
                        get: {
                            message
                        },
                        set: { value in
                            chat.message = value
                        })
                }
                HStack {
                    GenerateCodeFCChatMiniView(generateCodeFC: messageBinding)
                }
            } else {
                var messageBinding: Binding<String> {
                    Binding(
                        get: {
                            chat.message as? String ?? ""
                        },
                        set: { value in
                            chat.message = value
                        })
                }
                TextEditor(text: messageBinding)
                    .scrollContentBackground(.hidden)
                    .focused($focused)
            }
        }
        .padding(4)
        .background(RoundedRectangle(cornerRadius: 8.0)
            .stroke(Color.background)
            .opacity(isHovering || focused ? 1.0 : 0.0))
        .onHover{ hovering in
            withAnimation(.bouncy(duration: 0.5)) {
                isHovering = hovering
            }
        }
    }
    
}

#Preview {
    
    ChatView(
        chat: Chat(
            role: .user,
            message: GenerateCodeFC(files: [GenerateCodeFC.File(
                filepath: "~/Downloads/test_dir",
                content: "This is the new content for the file.")])),
//            message: "This is the user string message"),
        onDelete: {
            
        }
    )
    
}
