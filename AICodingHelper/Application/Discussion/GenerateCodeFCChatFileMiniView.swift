//
//  GenerateCodeFCChatFileMiniView.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/21/24.
//

import CodeEditor
import SwiftUI

struct GenerateCodeFCChatFileMiniView: View {
    
    @Binding var file: GenerateCodeFC.File
    
    @EnvironmentObject private var codeEditorSettingsViewModel: CodeEditorSettingsViewModel
    
    @State private var isExpanded: Bool = false
    
    @State private var expandedCodeEditorSelection: Range<String.Index> = "".startIndex..<"".startIndex
    @State private var miniCodeEditorSelection: Range<String.Index> = "".startIndex..<"".startIndex
    
    @State private var fileLanguage: CodeEditor.Language?
    
    init(file: Binding<GenerateCodeFC.File>) {
        self._file = file
        
        self._fileLanguage = State(initialValue: CodeEditorLanguageResolver.language(for: URL(fileURLWithPath: file.filepath.wrappedValue).pathExtension))
    }
    
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
                CodeEditor(
                    source: $file.content,
                    selection: $miniCodeEditorSelection,
                    language: $fileLanguage,
                    theme: $codeEditorSettingsViewModel.theme,
                    fontSize: .constant(12.0),
                    inset: CGSize(width: 14.0, height: 14.0))
                .focusable()
                .frame(height: 150.0)
                .scrollContentBackground(.hidden)
                .textFieldStyle(.plain)
                
                Button("\(Image(systemName: "arrow.up.left.and.arrow.down.right")) Expand") {
                    isExpanded = true
                }
                .padding(8)
            }
            .background(Colors.secondary.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 8.0))
        }
        .sheet(isPresented: $isExpanded) {
            VStack {
                CodeEditor(
                    source: $file.content,
                    selection: $expandedCodeEditorSelection,
                    language: $fileLanguage,
                    theme: $codeEditorSettingsViewModel.theme,
                    fontSize: .constant(14.0),
                    inset: CGSize(width: 14.0, height: 14.0))
                
                HStack {
                    Spacer()
                    
                    CodeEditorLanguageSelector(selectedLanguage: $fileLanguage)
                    
                    Button("Close") {
                        isExpanded = false
                    }
                    .keyboardShortcut(.defaultAction)
                }
                .padding()
            }
            .frame(minWidth: 350.0, idealWidth: 1050.0, minHeight: 300.0, idealHeight: 800.0)
        }
    }
    
}

#Preview {
    GenerateCodeFCChatFileMiniView(file: .constant(GenerateCodeFC.File(
        filepath: "~/Downloads/test_dir",
        content: "This is the new content for the file.\n\n\nmultiline")))
    .background(Color.foreground)
    .frame(width: 550.0, height: 500.0)
    .environmentObject(CodeEditorSettingsViewModel())
}
