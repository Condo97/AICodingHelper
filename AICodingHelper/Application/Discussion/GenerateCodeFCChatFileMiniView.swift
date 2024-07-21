//
//  GenerateCodeFCChatFileMiniView.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/21/24.
//

import SwiftUI

struct GenerateCodeFCChatFileMiniView: View {
    
    @Binding var file: GenerateCodeFC.File
    
    @State private var isExpanded: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4.0) {
            HStack(spacing: 8.0) {
                Text("Path")
                    .bold()
                Text("\(file.filepath)")
            }
            .font(.subheadline)
            .padding(.leading, 4)
            
            Text("Content")
                .bold()
                .font(.subheadline)
                .padding(.leading, 4)
            
            ZStack(alignment: .bottomTrailing) {
                TextEditor(text: $file.content)
                    .frame(height: 76.0)
                    .scrollContentBackground(.hidden)
                    .textFieldStyle(.plain)
                
                Button("\(Image(systemName: "arrow.up.left.and.arrow.down.right")) Expand") {
                    isExpanded = true
                }
            }
            .padding(8)
            .background(Colors.secondary.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 8.0))
        }
    }
    
}

#Preview {
    GenerateCodeFCChatFileMiniView(file: .constant(GenerateCodeFC.File(
        filepath: "~/Downloads/test_dir",
        content: "This is the new content for the file.\n\n\nmultiline")))
    .background(Color.foreground)
    .frame(width: 550.0, height: 500.0)
}
