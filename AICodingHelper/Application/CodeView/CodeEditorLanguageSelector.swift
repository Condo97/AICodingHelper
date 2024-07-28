//
//  CodeEditorLanguageSelector.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 6/26/24.
//

import CodeEditor
import Foundation
import SwiftUI


struct CodeEditorLanguageSelector: View {
    
    @Binding var selectedLanguage: CodeEditor.Language?

    var body: some View {
        Picker(selection: $selectedLanguage, content: {
            ForEach(CodeEditorLanguageResolver.allLanguages, id: \.self) { language in
                Text(language?.rawValue ?? "- None -")
            }
        }) {
            Text("Language:")
        }
        .frame(width: 200.0)
        .menuStyle(.automatic)
    }
    
}

#Preview {
    
    CodeEditorLanguageSelector(selectedLanguage: .constant(.tex))
    
}
