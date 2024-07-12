//
//  CodeEditorSettingsViewModel.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/9/24.
//

import CodeEditor
import Foundation
import SwiftUI


class CodeEditorSettingsViewModel: ObservableObject {
    
    @Published var theme: CodeEditor.ThemeName = UserDefaultsHelper.codeEditorTheme {
        didSet {
            UserDefaultsHelper.codeEditorTheme = theme
        }
    }
    
}
