//
//  GenerateCodeFCChatDisplayView.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/20/24.
//

import SwiftUI


struct GenerateCodeFCChatMiniView: View {
    
    @Binding var rootFilepath: String
    @Binding var generateCodeFC: GenerateCodeFC
    
    @FocusState private var focused
    
//    @State private var isHovering: Bool = false
    @State private var isApplied: Bool = false
    @State private var isExpanded: Bool = false
    @State private var isHoveringApplyButton: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8.0) {
            ForEach($generateCodeFC.output_files) { $file in
                GenerateCodeFCChatFileMiniViewContainer(
                    rootFilepath: $rootFilepath,
                    file: $file)
            }
        }
//        .background(isHovering ? Color.background.opacity(0.2) : .clear)
//        .onHover { hovering in
//            isHovering = hovering
//        }
    }
    
}

#Preview {
    
    GenerateCodeFCChatMiniView(
        rootFilepath: .constant("~/Downloads/test_dir"),
        generateCodeFC: .constant(GenerateCodeFC(
            output_files: [
                GenerateCodeFC.File(
                    filepath: "~/Downloads/test_dir/file.txt",
                    content: "This is the content of the file"),
                GenerateCodeFC.File(
                    filepath: "~/Downloads/test_dir/anotherfile.txt",
                    content: "This is the content of the second file")
            ])))
    .background(Color.foreground)
    .frame(width: 550.0, height: 500.0)
    
}
