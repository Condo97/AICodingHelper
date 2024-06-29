//
//  CodeViewModel.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 6/28/24.
//

import CodeEditor
import Foundation
import SwiftUI

class CodeViewModel: ObservableObject, Identifiable {
    
    @Published var filepath: String?
    @Published var openedFileText: String = ""
    @Published var openedFileTextSelection: Range<String.Index> = "".startIndex..<"".endIndex
    
    @Published var currentNarrowScope: Scope = .file
    
    @Published var openedFileLanguage: CodeEditor.Language = .tex
    
    @Published var narrowScopeStreamGenerationInitialSelection: Range<String.Index>?
    @Published var narrowScopeStreamGenerationCursorPosition: String.Index?
    
    
    init(filepath: String?) {
        self.filepath = filepath
    }
    
    
}
