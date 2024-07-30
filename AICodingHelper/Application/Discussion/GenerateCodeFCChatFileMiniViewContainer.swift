//
//  GenerateCodeFCChatFileMiniViewContainer.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/29/24.
//

import SwiftUI

struct GenerateCodeFCChatFileMiniViewContainer: View {
    
    @Binding var rootFilepath: String
    @Binding var file: GenerateCodeFC.File
    
    @State private var isApplied: Bool = false
    @State private var isHoveringApplyButton: Bool = false
    
    var body: some View {
        HStack {
            Button(action: {
                // Apply changes
                GenerateCodeFCApplier.applyFile($file.wrappedValue, rootFilepath: rootFilepath)
                
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
            
            GenerateCodeFCChatFileMiniView(file: $file)
        }
    }
    
}

#Preview {
    
    GenerateCodeFCChatFileMiniViewContainer(
        rootFilepath: .constant("~/Downloads/test_dir"),
        file: .constant(GenerateCodeFC.File(
            filepath: "~/Downloads/test_dir",
            content: "Test Content"))
    )
    
}
