//
//  CodeView.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 6/28/24.
//

import CodeEditor
import SwiftUI

struct CodeView: View {
    
//    @Binding var filepath: String?
    @Binding var codeViewModel: CodeViewModel
    
    
    @Environment(\.undoManager) private var undoManager
    
    @StateObject private var chatGenerator: ChatGenerator = ChatGenerator()
    
//    @State private var currentNarrowScope: Scope = .file
    
//    @State private var openedFileText: String = ""
//    @StateObject private var openedFileText_workaround_undoableOpenedTextObservable: CodeViewModel = CodeViewModel()
//    @State private var openedFileTextSelection: Range<String.Index> = "".startIndex..<"".startIndex
//    @State private var openedFileLanguage: CodeEditor.Language = .tex
//    
//    @State private var narrowScopeStreamGenerationInitialSelection: Range<String.Index>?
//    @State private var narrowScopeStreamGenerationCursorPosition: String.Index?
    
    
    var body: some View {
        ZStack {
            // Code Editor Container
            CodeEditorContainer(
                fileText: $codeViewModel.openedFileText,
                fileSelection: $codeViewModel.openedFileTextSelection,
                fileLanguage: $codeViewModel.openedFileLanguage)
            
            // Narrow Scope Controls
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    NarrowScopeControlsView(
                        scope: $codeViewModel.currentNarrowScope,
                        onSubmit: { actionType in
                            generateChat(
                                actionType: actionType,
                                useProjectContext: false,
                                input: String(codeViewModel.openedFileText[codeViewModel.openedFileTextSelection]),
                                scope: codeViewModel.currentNarrowScope)
                        })
                    .padding()
                }
            }
        }
        .onReceive(codeViewModel.$filepath) { filepath in
            if let filepath = filepath {
                // Set fileText
                do {
                    codeViewModel.openedFileText = try String(contentsOfFile: filepath)
                } catch {
                    // TODO: Handle Errors
                    print("Error getting contents of file in CodeEditorContainer... \(error)")
                }
                
                // Set fileLanguage
                let filepathURL = URL(fileURLWithPath: filepath)
                let fileExtension = filepathURL.pathExtension
                codeViewModel.openedFileLanguage = CodeEditorLanguageResolver.language(for: fileExtension)
            }
        }
        .onReceive(codeViewModel.$openedFileText) { fileText in
            // Update file contents
            if let filepath = codeViewModel.filepath {
                do {
                    try fileText.write(toFile: filepath, atomically: true, encoding: .utf8)
                } catch {
                    // TODO: Handle Errors
                    print("Error writing to file in CodeEditorContainer... \(error)")
                }
            }
        }
        .onChange(of: codeViewModel.openedFileTextSelection) {
            codeViewModel.currentNarrowScope = codeViewModel.openedFileTextSelection.lowerBound == codeViewModel.openedFileTextSelection.upperBound ? .file : .highlight
        }
        .onReceive(chatGenerator.$isStreaming) { newValue in
            // Do scope related actions on successful stream start TODO: Make sure isStreaming only sets true on successful stream
            switch chatGenerator.streamingChatScope {
            case .project:
                break
            case .directory:
                break
//            case .file:
//                if newValue {
//                    // Set openedFileText to empty string
//                    openedFileText = ""
//                    
//                    // Set narrowScopeStreamGenerationCursorPosition to openedFileText startIndex
//                    narrowScopeStreamGenerationCursorPosition = openedFileText.startIndex
//                    
//                    // Set openedFileTextSelection to range from narrowScopeStreamGenerationCursorPosition to narrowScopeStreamGenerationCursorPosition
//                    openedFileTextSelection = narrowScopeStreamGenerationCursorPosition!..<narrowScopeStreamGenerationCursorPosition!
//                }
            case .file, .highlight:
                if newValue {
                    // Register opened file text undo, delete narrowScopeStreamGenerationInitialSelection subrange, set narrowScopeStreamGenerationCursorPosition to narrowScopeStreamGenerationInitialSelection lowerBound, and set openedFileTextSelection to a range from narrowScopeStreamGenerationCursorPosition to narrowScopeStreamGenerationCursorPosition
                    if let narrowScopeStreamGenerationInitialSelection = codeViewModel.narrowScopeStreamGenerationInitialSelection {
                        registerOpenedFileTextUndo()
                        
                        codeViewModel.openedFileText.replaceSubrange(codeViewModel.openedFileTextSelection, with: "")
                        
                        codeViewModel.narrowScopeStreamGenerationCursorPosition = narrowScopeStreamGenerationInitialSelection.lowerBound
                        codeViewModel.openedFileTextSelection = codeViewModel.narrowScopeStreamGenerationCursorPosition!..<codeViewModel.narrowScopeStreamGenerationCursorPosition!
                    }
                }
            case .none:
                break
            }
        }
        .onReceive(chatGenerator.$streamingChatDelta) { newValue in
            // If chatGenerator is perform scoped operations for newValue
            switch chatGenerator.streamingChatScope {
            case .project:
                // TODO: Project scope
                print()
            case .directory:
                // TODO: Directory scope
                print()
            case .file, .highlight:
                if let newValue = newValue {
                    // Insert newValue at narrowScopeStreamGenerationCursorPosition or if null startIndex
                    codeViewModel.openedFileText.insert(contentsOf: newValue, at: codeViewModel.narrowScopeStreamGenerationCursorPosition ?? codeViewModel.openedFileText.startIndex)
                    
                    // Set narrowScopeStreamGenerationCursorPosition to itself offset by newValue count
                    codeViewModel.narrowScopeStreamGenerationCursorPosition = codeViewModel.openedFileText.index(codeViewModel.narrowScopeStreamGenerationCursorPosition ?? codeViewModel.openedFileText.startIndex, offsetBy: newValue.count)
                    
                    // Set openedFileTextSelection to range from narrowScopeStreamGenerationCursorPosition to narrowScopeStreamGenerationCursorPosition
                    if let narrowScopeStreamGenerationCursorPosition = codeViewModel.narrowScopeStreamGenerationCursorPosition {
                        codeViewModel.openedFileTextSelection = narrowScopeStreamGenerationCursorPosition..<narrowScopeStreamGenerationCursorPosition
                    }
                }
            case .none:
                break
            }
        }
    }
    
    
    func generateChat(actionType: ActionType, useProjectContext: Bool, input: String, scope: Scope) {
        Task {
            if scope == .highlight {
                // If scope is highlight set narrowScopeStreamGenerationInitialSelection to openedFileTextSelection
                await MainActor.run {
                    codeViewModel.narrowScopeStreamGenerationInitialSelection = codeViewModel.openedFileTextSelection
                }
            } else if scope == .file {
                // If scope is file set narrowScopeStreamGenerationInitialSelection to openedFileText startIndex and endIndex
                await MainActor.run {
                    codeViewModel.narrowScopeStreamGenerationInitialSelection = codeViewModel.openedFileText.startIndex..<codeViewModel.openedFileText.endIndex
                }
            } else {
                // If scope is anything else return TODO: Handle Errors
                print("Scope \(scope) is not supported in narrow scope generation!")
                return
            }
            
            // Ensure authToken
            let authToken: String
            do {
                authToken = try await AuthHelper.ensure()
            } catch {
                // TODO: Handle Errors
                print("Error ensuring authToken in MainView... \(error)")
                return
            }
            
            // Stream Chat
            do {
                try await chatGenerator.streamChat(
                    authToken: authToken,
                    model: .GPT4o,
                    action: actionType,
                    language: codeViewModel.openedFileLanguage,
                    context: [], // TODO: Implement full project context
                    input: input,
                    scope: scope)
            } catch {
                // TODO: Handle Errors
                print("Error streaming chat in MainView... \(error)")
            }
        }
    }
    
    private func registerOpenedFileTextUndo() {
        registerOpenedFileTextUndo(
            oldString: codeViewModel.openedFileText,
            oldStringSelection: codeViewModel.openedFileTextSelection)
    }
    
    private func registerOpenedFileTextUndo(oldString: String, oldStringSelection: Range<String.Index>) {
        undoManager?.registerUndo(withTarget: codeViewModel) { target in
            let currentString = target.openedFileText
            let currentStringSelection = target.openedFileTextSelection
            
            target.openedFileText = oldString
            target.openedFileTextSelection = oldStringSelection
            
            registerOpenedFileTextRedo(newString: currentString, newStringSelection: currentStringSelection)
        }
        undoManager?.setActionName("Edit Text")
    }
    
    private func registerOpenedFileTextRedo(newString: String, newStringSelection: Range<String.Index>) {
        undoManager?.registerUndo(withTarget: codeViewModel) { target in
            let currentString = target.openedFileText
            let currentStringSelection = target.openedFileTextSelection
            
            target.openedFileText = newString
            target.openedFileTextSelection = newStringSelection
            
            registerOpenedFileTextUndo(oldString: currentString, oldStringSelection: currentStringSelection)
        }
        undoManager?.setActionName("Redo Edit")
    }
    
}

//#Preview {
//    CodeView(
//        codeViewModel: CodeViewModel(filepath: "~/Downloads/test_dir/testing.txt")
//    )
//}
