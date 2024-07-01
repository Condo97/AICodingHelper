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
    
    @ObservedObject private var codeViewModel_ObservedObject: CodeViewModel // INCLUDING THIS FIXES THE ISSUES I WAS HAVING WITH THE codeViewModel BINDING NOT UPDATING THE VIEW! WHAT why IS THIS A GLITCH did I find something? nice :) anyways this seems to allow the View to get updates triggered and it works now
    
    /**
     From Apple documentation:
     Structure
     ObservedObject
     A property wrapper type that subscribes to an observable object and invalidates a view whenever the observable object changes.
     https://developer.apple.com/documentation/swiftui/observedobject
     
     So I mean it looks like just including it will make it invalidate the view whenever the observable object changes which would I guess make those bindings to the binding codeiViewModel ObservedObject update correctly! :)
     */
    
    
    @Environment(\.undoManager) private var undoManager
    
    @StateObject private var chatGenerator: NarrowScopeChatGenerator = NarrowScopeChatGenerator() // This is probably what is causing the view to receive updates when generating a chat and not deleing before generating chat and undoing, but now it works with codeViewMode_ObservedObject just fine
    
    
    private var isCodeEditorEditingDisabled: Binding<Bool> {
        Binding(
            get: {
                // Disabled if chatGenerator isLoading or isStreaming
                chatGenerator.isLoading || chatGenerator.isStreaming
            },
            set: { value in
                // No actions
            })
    }
    
    
    init(codeViewModel: Binding<CodeViewModel>) {
        self._codeViewModel = codeViewModel
        self.codeViewModel_ObservedObject = codeViewModel.wrappedValue // What the heck.. for some reason, including this allows CodeEditorContainer to get updated values for its bindings from the codeViewModel binding.. what do you know, there it is lol.. yay I think this should work then. Maybe since it's observed it's just automatically looking for view updates of the like
    }
    
    
    var body: some View {
        ZStack {
            // Code Editor Container
            CodeEditorContainer(
                fileText: $codeViewModel.openedFileText,//$glitchyFix_fileText,
                fileSelection: $codeViewModel.openedFileTextSelection,
                fileLanguage: $codeViewModel.openedFileLanguage)
            .disabled(isCodeEditorEditingDisabled.wrappedValue)
//            .onChange(of: glitchyFix_fileText) {
//                print("CHANGED")
//                codeViewModel.openedFileText = glitchyFix_fileText
//            }
            
            // Loading overlay and progress view
            if isCodeEditorEditingDisabled.wrappedValue {
                ZStack {
                    Colors.foreground
                        .opacity(0.4)
                    
                    VStack {
                        Text(chatGenerator.isLoading ? "Loading..." : "Streaming...")
                        
                        ProgressView()
                            .tint(Colors.foregroundText)
                    }
                }
            }
            
            // Narrow Scope Controls
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    NarrowScopeControlsView(
                        scope: $codeViewModel.currentNarrowScope,
                        onSubmit: { actionType, userInput in
                            generateChat(
                                actionType: actionType,
                                userInput: userInput,
                                useProjectContext: false,
                                scope: codeViewModel.currentNarrowScope)
                        })
                    .padding(8)
                    .background(Colors.foreground)
                    .clipShape(RoundedRectangle(cornerRadius: 58.0))
                    .shadow(color: Colors.foregroundText.opacity(0.05), radius: 8.0)
                    .padding(.bottom, 48.0)
                    .padding(.trailing)
                }
            }
        }
        .onReceive(codeViewModel.$filepath) { filepath in
            if let filepath = filepath {
                // Set fileText
                do {
                                    codeViewModel.openedFileText = try String(contentsOfFile: filepath)
                                } catch {
                                    print("Error getting contents of file in CodeView... \(error)")
                                }

//                                let filepathURL = URL(fileURLWithPath: filepath)
//                                let fileExtension = filepathURL.pathExtension
//                                codeViewModel.openedFileLanguage = CodeEditorLanguageResolver.language(for: fileExtension)
                
                // Set fileLanguage
                let filepathURL = URL(fileURLWithPath: filepath)
                let fileExtension = filepathURL.pathExtension
                codeViewModel.openedFileLanguage = CodeEditorLanguageResolver.language(for: fileExtension)
            }
        }
        .onReceive(codeViewModel.$openedFileText) { fileText in
            // Update file contents
            if let filepath = codeViewModel.filepath {
                // Get file contents
                
                // Check if
                
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
            case .file:
                if newValue {
                    // Set openedFileText to empty string
                    codeViewModel.openedFileText = ""
                    
                    // Set narrowScopeStreamGenerationCursorPosition to openedFileText startIndex
                    codeViewModel.narrowScopeStreamGenerationCursorPosition = codeViewModel.openedFileText.startIndex
                    
                    // Set openedFileTextSelection to range from narrowScopeStreamGenerationCursorPosition to narrowScopeStreamGenerationCursorPosition
                    codeViewModel.openedFileTextSelection = codeViewModel.narrowScopeStreamGenerationCursorPosition!..<codeViewModel.narrowScopeStreamGenerationCursorPosition!
                }
                
//                // Continue switch to next case
//                fallthrough
            case .highlight:
                if newValue {
                    // Register opened file text undo, delete narrowScopeStreamGenerationInitialSelection subrange, set narrowScopeStreamGenerationCursorPosition to narrowScopeStreamGenerationInitialSelection lowerBound, and set openedFileTextSelection to a range from narrowScopeStreamGenerationCursorPosition to narrowScopeStreamGenerationCursorPosition
                    if let narrowScopeStreamGenerationInitialSelection = codeViewModel.narrowScopeStreamGenerationInitialSelection {
                        registerOpenedFileTextUndo()
                        
                        codeViewModel.openedFileText.replaceSubrange(narrowScopeStreamGenerationInitialSelection, with: "")
                        
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
    
    
    func generateChat(actionType: ActionType, userInput: String?, useProjectContext: Bool, scope: Scope) {
        Task {
            var context: [String] = []
            
            // Create additionalInput as nil
            var additionalInput: String?
            
            if scope == .highlight {
                // If scope is highlight set additionalInput to selection of opened file text, append opened file text with explanation and minimal instructions to context, and set narrowScopeStreamGenerationInitialSelection to openedFileTextSelection
                additionalInput = String(codeViewModel.openedFileText[codeViewModel.openedFileTextSelection])
                
                context.append("This is the entire file for which you are to process a selection of. IMPORTANT: Respond as if you are replacing exactly the selection provided.\n\n\(codeViewModel.openedFileText)")
                
                await MainActor.run {
                    codeViewModel.narrowScopeStreamGenerationInitialSelection = codeViewModel.openedFileTextSelection
                }
            } else if scope == .file {
                // If scope is file set input to opened file text and narrowScopeStreamGenerationInitialSelection to openedFileText startIndex and endIndex
                
                additionalInput = codeViewModel.openedFileText
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
                    additionalInput: additionalInput,
                    language: codeViewModel.openedFileLanguage,
                    context: context, // TODO: Implement full project context
                    input: userInput ?? "",
                    scope: scope)
            } catch {
                // TODO: Handle Errors
                print("Error streaming chat in MainView... \(error)")
            }
        }
    }
    
    private func registerOpenedFileTextUndo() {
        registerOpenedFileTextUndo(
            oldText: codeViewModel.openedFileText,
            oldTextSelection: codeViewModel.openedFileTextSelection)
//        undoWrapper.registerUndo(
//            undoManager: undoManager,
//            oldString: codeViewModel.openedFileText,
//            oldStringSelection: codeViewModel.openedFileTextSelection,
//            onUndo: { newString, newStringSelection in
//                let currentFileText = codeViewModel.openedFileText
//                let currentFileTextSelection = codeViewModel.openedFileTextSelection
//                
//                codeViewModel.openedFileText = newString
//                codeViewModel.openedFileTextSelection = newStringSelection
//                
//                return (currentFileText, currentFileTextSelection)
//            })
    }
    
    private func registerOpenedFileTextUndo(oldText: String, oldTextSelection: Range<String.Index>) {
        undoManager?.registerUndo(withTarget: codeViewModel) { target in
            let currentText = target.openedFileText
            let currentTextSelection = target.openedFileTextSelection
            
            DispatchQueue.main.async {
                target.openedFileText = oldText // I bet if we did a replace instead of a set here it would work fine without the ObservableObject.. see it was triggering a view update fine when updating the existing openedFileText object like this codeViewModel.openedFileText.replaceSubrange(codeViewModel.openedFileTextSelection, with: ""), but when setting it to a new object or reference or whatever it doesn't seem to propogate the update.. maybe the Binding of an ObservableObject can detect and propogate if an object is modified but not if its reference is changed
                target.openedFileTextSelection = oldTextSelection
                
                self.codeViewModel = target
            }
            
            registerOpenedFileTextRedo(newText: currentText, newTextSelection: currentTextSelection)
        }
        undoManager?.setActionName("Edit Text")
    }
    
    private func registerOpenedFileTextRedo(newText: String, newTextSelection: Range<String.Index>) {
        undoManager?.registerUndo(withTarget: codeViewModel) { target in
            let currentText = target.openedFileText
            let currentTextSelection = target.openedFileTextSelection
            
            target.openedFileText = newText
            target.openedFileTextSelection = newTextSelection
            
            registerOpenedFileTextUndo(oldText: currentText, oldTextSelection: currentTextSelection)
        }
        undoManager?.setActionName("Redo Edit")
    }
    
}

#Preview {
    CodeView(
        codeViewModel: .constant(CodeViewModel(filepath: "~/Downloads/test_dir/testing.txt"))
    )
}
