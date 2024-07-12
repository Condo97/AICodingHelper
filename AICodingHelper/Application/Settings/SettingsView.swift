//
//  SettingsView.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/9/24.
//

import CodeEditor
import SwiftUI

struct SettingsView: View {
    
    
    @EnvironmentObject private var codeEditorSettingsViewModel: CodeEditorSettingsViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Settings")
                .font(.title)
            
            HStack {
                Picker("Select Theme", selection: $codeEditorSettingsViewModel.theme) {
                    ForEach(CodeEditor.availableThemes) { theme in
                        Text(theme.rawValue)
                            .tag(theme)
                    }
                }
                Spacer()
            }
        }
        .padding()
    }
    
}

#Preview {
    
    SettingsView()
    
}
