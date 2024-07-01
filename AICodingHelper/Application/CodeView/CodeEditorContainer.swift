//
//  CodeEditorContainer.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 6/26/24.
//

import CodeEditor
import SwiftUI

struct CodeEditorContainer: View {
    
    @Binding var fileText: String
    @Binding var fileSelection: Range<String.Index>
    @Binding var fileLanguage: CodeEditor.Language?
    
    
    @State private var fontSize: CGFloat? = nil
    
    
//    @State private var fileLanguage: CodeEditor.Language = .tex
    
//    @State private var fileSelection: Range<String.Index> = "".startIndex..<"".startIndex
    
    
    var body: some View {
        VStack {
            // Code Editor
            CodeEditor(
                source: $fileText,
                selection: $fileSelection,
                language: $fileLanguage,
                fontSize: $fontSize,
                inset: CGSize(width: 0, height: 140.0),
                allowsUndo: false)
            .padding(.top, -140)
            .onChange(of: fileLanguage) {
                print("Changed Language \(fileLanguage)")
            }
            
            // Language Selector
            HStack {
                Spacer()
                CodeEditorLanguageSelector(selectedLanguage: $fileLanguage)
            }
        }
    }
    
}

//#Preview {
//    
//    CodeEditorContainer(
//        filepath: .constant("~/Downloads/test_dir/testing.txt"),
//        fileText: .constant(""),
//        fileSelection: .constant("".startIndex..<"".startIndex),
//        fileLanguage: .constant(.tex)
//    )
//    
//}
