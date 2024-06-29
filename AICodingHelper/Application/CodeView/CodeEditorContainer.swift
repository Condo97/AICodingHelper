//
//  CodeEditorContainer.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 6/26/24.
//

import CodeEditor
import SwiftUI

struct CodeEditorContainer: View {
    
    @Binding var filepath: String?
    @Binding var fileText: String
    @Binding var fileSelection: Range<String.Index>
    @Binding var fileLanguage: CodeEditor.Language
    
    
//    @State private var fileLanguage: CodeEditor.Language = .tex
    
//    @State private var fileSelection: Range<String.Index> = "".startIndex..<"".startIndex
    
    
    var body: some View {
        VStack {
            // Code Editor
            CodeEditor(
                source: $fileText,
                selection: $fileSelection,
                language: fileLanguage,
//                fontSize: .constant(30.0),
                inset: CGSize(width: 0, height: 140.0))
            .padding(.top, -140)
            
            // Language Selector
            HStack {
                Spacer()
                CodeEditorLanguageSelector(selectedLanguage: $fileLanguage)
            }
        }
        .onChange(of: filepath) {
            if let filepath = filepath {
                // Set fileText
                do {
                    fileText = try String(contentsOfFile: filepath)
                } catch {
                    // TODO: Handle Errors
                    print("Error getting contents of file in CodeEditorContainer... \(error)")
                }
                
                // Set fileLanguage
                let filepathURL = URL(fileURLWithPath: filepath)
                let fileExtension = filepathURL.pathExtension
                fileLanguage = CodeEditorLanguageResolver.language(for: fileExtension)
            }
        }
        .onChange(of: fileText) {
            // Update file contents
            if let filepath = filepath {
                do {
                    try fileText.write(toFile: filepath, atomically: true, encoding: .utf8)
                } catch {
                    // TODO: Handle Errors
                    print("Error writing to file in CodeEditorContainer... \(error)")
                }
            }
        }
//        .onChange(of: fileSelection) {
//            selectedText = String(fileText[fileSelection])
//        }
    }
    
}

#Preview {
    
    CodeEditorContainer(
        filepath: .constant("~/Downloads/test_dir/testing.txt"),
        fileText: .constant(""),
        fileSelection: .constant("".startIndex..<"".startIndex),
        fileLanguage: .constant(.tex)
    )
    
}
