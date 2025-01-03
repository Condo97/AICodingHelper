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
    
    
    @EnvironmentObject private var codeEditorSettingsViewModel: CodeEditorSettingsViewModel
    
    
    @State private var fontSize: CGFloat? = nil
    
    
//    @State private var fileLanguage: CodeEditor.Language = .tex
    
//    @State private var fileSelection: Range<String.Index> = "".startIndex..<"".startIndex
    
    
    var body: some View {
        VStack(spacing: 0.0) {
            // Code Editor
            CodeEditor(
                source: $fileText,
                selection: $fileSelection,
                language: $fileLanguage,
                theme: $codeEditorSettingsViewModel.theme,
                fontSize: $fontSize,
//                inset: CGSize(width: 0, height: 140.0),
                allowsUndo: false)
//            .padding(.top, -140)
            .onChange(of: fileLanguage) { newValue in
                print("Changed Language \(newValue)")
            }
            
//            Spacer()
            
            // Language Selector
            HStack {
                Spacer()
                CodeEditorLanguageSelector(selectedLanguage: $fileLanguage)
            }
            .padding(8)
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
