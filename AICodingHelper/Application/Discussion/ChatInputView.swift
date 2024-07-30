//
//  ChatInputView.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/28/24.
//

import SwiftUI

struct ChatInputView: View {
    
    @Binding var newInput: String
    @Binding var newFilepaths: [String]
    @State var buildCodeGenerationText: LocalizedStringKey = "Build Code"
    @State var chatText: LocalizedStringKey = "Chat"
    var doBuildCodeGeneration: () -> Void
    var doChatGeneration: () -> Void
    
    @FocusState private var focused
    
    @State private var isShowingDirectoryImporter: Bool = false
    @State private var isLoading: Bool = false
    
    var body: some View {
        VStack {
            ZStack(alignment: .topLeading) {
                TextEditor(text: $newInput)
                    .scrollContentBackground(.hidden)
                    .focused($focused)
                    .frame(height: 80.0)
                
                Text("Enter Message...")
                    .opacity(focused || !newInput.isEmpty ? 0.0 : 0.4)
                    .onTapGesture {
                        focused = true
                    }
            }
            
            HStack(alignment: .bottom) {
                VStack(alignment: .leading) {
                    HStack {
                        Text("Files")
                            .font(.subheadline)
                            .bold()
                        
                        Button("\(Image(systemName: "plus"))") {
                            isShowingDirectoryImporter = true
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.top, 2)
                    
                    VStack(alignment: .leading) {
                        ForEach(newFilepaths, id: \.self) { filepath in
                            HStack {
                                Button("\(Image(systemName: "xmark"))") {
                                    newFilepaths.removeAll(where: {$0 == filepath})
                                }
                                .buttonStyle(PlainButtonStyle())
                                Text(filepath)
                                    .lineLimit(1)
                                    .truncationMode(.head)
                                    .font(.system(size: 9.0))
                                    .opacity(0.6)
                            }
                        }
                        
                        Text("Drag Files Here")
                            .font(.subheadline)
                            .opacity(isLoading ? 0.2 : 0.6)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 8.0)
                        .stroke(Color.background.opacity(isLoading ? 0.2 : 0.6), style: StrokeStyle(dash: [5, 3])))
                    .onDrop(of: [.text], isTargeted: nil, perform: { providers in
                        if let provider = providers.first {
                            provider.loadObject(ofClass: NSString.self, completionHandler: { providerReading, error in
                                if let filepath = providerReading as? String {
                                    if !newFilepaths.contains(where: {$0 == filepath}) {
                                        newFilepaths.append(filepath)
                                    }
                                }
                            })
                        }
                        
                        return true
                    })
                }
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Button(buildCodeGenerationText) {
                        doBuildCodeGeneration()
                    }
                    .help("Build Code - command+shift+return")
                    
                    Button(action: {
                        doChatGeneration()
                    }) {
                        HStack {
                            Text(chatText)
                            HStack(spacing: 0.0) {
                                Image(systemName: "command")
                                    .imageScale(.small)
                                Image(systemName: "return")
                                    .imageScale(.small)
                            }
                        }
                    }
                    .help("Chat - command+return")
                    .keyboardShortcut(.defaultAction)
                }
            }
            .disabled(isLoading)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 4.0)
            .stroke(focused ? Colors.element : Colors.background, lineWidth: focused ? 2.0 : 1.0))
    }
    
}

#Preview {
    
    ChatInputView(
        newInput: .constant(""),
        newFilepaths: .constant([]),
        doBuildCodeGeneration: {
            
        },
        doChatGeneration: {
            
        }
    )
    
}
