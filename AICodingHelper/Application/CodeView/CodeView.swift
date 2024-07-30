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
    @Binding var hasSelection: Bool
    
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
    
    @EnvironmentObject private var activeSubscriptionUpdater: ActiveSubscriptionUpdater
    
    
//    @StateObject private var chatGenerator: NarrowScopeChatGenerator = NarrowScopeChatGenerator() // This is probably what is causing the view to receive updates when generating a chat and not deleing before generating chat and undoing, but now it works with codeViewMode_ObservedObject just fine
    
    @State private var cachedCodeEditorContainerFileTextForUndo: String? // The previous code editor container file text, since we're updating the undo on selection, to prevent undo from saving when the selector is moved
    
    @State private var alertShowingInvalidOpenAIKey: Bool = false
    
    
    private var isCodeEditorEditingDisabled: Binding<Bool> {
        Binding(
            get: {
                // Disabled if chatGenerator isLoading or isStreaming
                codeViewModel.isLoading || codeViewModel.isStreaming
            },
            set: { value in
                // No actions
            })
    }
    
    private var undoCacheSavingCodeEditorFileText: Binding<String> {
        Binding(
            get: {
                codeViewModel.openedFileText
            },
            set: { value in
                // Handle undo char delay stuff
                if value != cachedCodeEditorContainerFileTextForUndo,
                   let undoManager = undoManager {
                    codeViewModel.saveUndo(
                        undoManager: undoManager,
                        oldFileText: codeViewModel.openedFileText,
                        oldFileTextSelection: codeViewModel.openedFileTextSelection)
                   cachedCodeEditorContainerFileTextForUndo = value
                }
                
                codeViewModel.openedFileText = value
            })
    }
    
    private var undoSavingCodeEditorContainerFileTextSelection: Binding<Range<String.Index>> {
        Binding(
            get: {
                codeViewModel.openedFileTextSelection
            },
            set: { value in
                // Handle undo char delay stuff
                if codeViewModel.openedFileText != cachedCodeEditorContainerFileTextForUndo,
                   let undoManager = undoManager {
                    codeViewModel.saveUndo(
                        undoManager: undoManager,
                        oldFileText: codeViewModel.openedFileText,
                        oldFileTextSelection: value)
                   cachedCodeEditorContainerFileTextForUndo = codeViewModel.openedFileText
                }
                
                // Set openedFileText to value
                codeViewModel.openedFileTextSelection = value
            })
    }
    
    
    init(codeViewModel: Binding<CodeViewModel>, hasSelection: Binding<Bool>) {
        self._codeViewModel = codeViewModel
        self._hasSelection = hasSelection
        self.codeViewModel_ObservedObject = codeViewModel.wrappedValue // What the heck.. for some reason, including this allows CodeEditorContainer to get updated values for its bindings from the codeViewModel binding.. what do you know, there it is lol.. yay I think this should work then. Maybe since it's observed it's just automatically looking for view updates of the like
    }
    
    
    var body: some View {
        ZStack {
            // Code Editor Container
            CodeEditorContainer(
                fileText: undoCacheSavingCodeEditorFileText,
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
                        Text(codeViewModel.isLoading ? "Loading..." : "Streaming...")
                        
                        ProgressView()
                            .tint(Colors.foregroundText)
                    }
                }
            }
            
//            // Narrow Scope Controls
//            VStack {
//                Spacer()
//                HStack {
//                    Spacer()
//                    NarrowScopeControlsView(
//                        scope: $codeViewModel.currentNarrowScope,
//                        onSubmit: { actionType, additionalInput in
//                            generateChat(
//                                actionType: actionType,
//                                additionalInput: additionalInput,
//                                useProjectContext: false,
//                                scope: codeViewModel.currentNarrowScope)
//                        })
//                    .padding(8)
//                    .background(Colors.foreground)
//                    .clipShape(RoundedRectangle(cornerRadius: 58.0))
//                    .shadow(color: Colors.foregroundText.opacity(0.05), radius: 8.0)
//                    .padding(.bottom, 48.0)
//                    .padding(.trailing)
//                }
//            }
        }
        .onReceive(codeViewModel.$filepath) { filepath in
            // When filepath is updated set cachedCodeEditorContainerFileTextForUndo to nil
            cachedCodeEditorContainerFileTextForUndo = nil
        }
//        .onReceive(codeViewModel.$openedFileText) { fileText in
//            // Update file contents
//            if let filepath = codeViewModel.filepath {
//                do {
//                    try fileText.write(toFile: filepath, atomically: true, encoding: .utf8)
//                } catch {
//                    // TODO: Handle Errors
//                    print("Error writing to file in CodeEditorContainer... \(error)")
//                }
//            }
//        }
        .onChange(of: codeViewModel.openedFileTextSelection) { newValue in
            hasSelection = newValue.lowerBound != newValue.upperBound
        }
        .onReceive(codeViewModel.$invalidOpenAIKey) { newValue in
            if newValue {
                // Set openAIKeyIsValid to false and show alert
                activeSubscriptionUpdater.openAIKeyIsValid = false
                alertShowingInvalidOpenAIKey = true
            }
        }
        .alert("Invalid OpenAI Key", isPresented: $alertShowingInvalidOpenAIKey, actions: {
            Button("Close") {
                
            }
        }, message: {
            Text("Your Open AI API Key is invalid and your plan will be used until it is updated. If you believe this is an error please report it!")
        })
//        .onReceive(chatGenerator.$isStreaming) { newValue in
//            // Do scope related actions on successful stream start TODO: Make sure isStreaming only sets true on successful stream
//            switch chatGenerator.streamingChatScope {
//            case .project:
//                break
//            case .directory:
//                break
//            case .file:
//                if newValue {
//                    // Save undo
//                    if let undoManager = undoManager {
//                        codeViewModel.saveUndo(undoManager: undoManager)
//                    }
//                    
//                    // Set openedFileText to empty string
//                    codeViewModel.openedFileText = ""
//                    
//                    // Set narrowScopeStreamGenerationCursorPosition to openedFileText startIndex
//                    codeViewModel.narrowScopeStreamGenerationCursorPosition = codeViewModel.openedFileText.startIndex
//                    
//                    // Set openedFileTextSelection to range from narrowScopeStreamGenerationCursorPosition to narrowScopeStreamGenerationCursorPosition
//                    codeViewModel.openedFileTextSelection = codeViewModel.narrowScopeStreamGenerationCursorPosition!..<codeViewModel.narrowScopeStreamGenerationCursorPosition!
//                }
//            case .highlight:
//                if newValue {
//                    // Save undo, delete narrowScopeStreamGenerationInitialSelection subrange, set narrowScopeStreamGenerationCursorPosition to narrowScopeStreamGenerationInitialSelection lowerBound, and set openedFileTextSelection to a range from narrowScopeStreamGenerationCursorPosition to narrowScopeStreamGenerationCursorPosition
//                    if let narrowScopeStreamGenerationInitialSelection = codeViewModel.narrowScopeStreamGenerationInitialSelection {
//                        if let undoManager = undoManager {
//                            codeViewModel.saveUndo(undoManager: undoManager)
//                        }
//                        codeViewModel.openedFileText.replaceSubrange(narrowScopeStreamGenerationInitialSelection, with: "")
//                        
//                        codeViewModel.narrowScopeStreamGenerationCursorPosition = narrowScopeStreamGenerationInitialSelection.lowerBound
//                        codeViewModel.openedFileTextSelection = codeViewModel.narrowScopeStreamGenerationCursorPosition!..<codeViewModel.narrowScopeStreamGenerationCursorPosition!
//                    }
//                }
//            case .none:
//                break
//            }
//        }
//        .onReceive(chatGenerator.$streamingChatDelta) { newValue in
//            // If chatGenerator is perform scoped operations for newValue
//            switch chatGenerator.streamingChatScope {
//            case .project:
//                // TODO: Project scope
//                print()
//            case .directory:
//                // TODO: Directory scope
//                print()
//            case .file, .highlight:
//                if let newValue = newValue {
//                    // Insert newValue at narrowScopeStreamGenerationCursorPosition or if null startIndex
//                    codeViewModel.openedFileText.insert(contentsOf: newValue, at: codeViewModel.narrowScopeStreamGenerationCursorPosition ?? codeViewModel.openedFileText.startIndex)
//                    
//                    // Set narrowScopeStreamGenerationCursorPosition to itself offset by newValue count
//                    codeViewModel.narrowScopeStreamGenerationCursorPosition = codeViewModel.openedFileText.index(codeViewModel.narrowScopeStreamGenerationCursorPosition ?? codeViewModel.openedFileText.startIndex, offsetBy: newValue.count)
//                    
//                    // Set openedFileTextSelection to range from narrowScopeStreamGenerationCursorPosition to narrowScopeStreamGenerationCursorPosition
//                    if let narrowScopeStreamGenerationCursorPosition = codeViewModel.narrowScopeStreamGenerationCursorPosition {
//                        codeViewModel.openedFileTextSelection = narrowScopeStreamGenerationCursorPosition..<narrowScopeStreamGenerationCursorPosition
//                    }
//                }
//            case .none:
//                break
//            }
//        }
    }
    
    
//    func generateChat(actionType: ActionType, additionalInput: String?, useProjectContext: Bool, scope: Scope) {
//        Task {
//            var context: [String] = []
//            
//            // Create input
//            var input: String
//            if scope == .highlight {
//                // If scope is highlight set additionalInput to selection of opened file text, append opened file text with explanation and minimal instructions to context, and set narrowScopeStreamGenerationInitialSelection to openedFileTextSelection
//                input = String(codeViewModel.openedFileText[codeViewModel.openedFileTextSelection])
//                
//                context.append("This is the entire file for which you are to process a selection of. IMPORTANT: Respond as if you are replacing exactly the selection provided.\n\n\(codeViewModel.openedFileText)")
//                
//                await MainActor.run {
//                    codeViewModel.narrowScopeStreamGenerationInitialSelection = codeViewModel.openedFileTextSelection
//                }
//            } else if scope == .file {
//                // If scope is file set input to opened file text and narrowScopeStreamGenerationInitialSelection to openedFileText startIndex and endIndex
//                
//                input = codeViewModel.openedFileText
//                await MainActor.run {
//                    codeViewModel.narrowScopeStreamGenerationInitialSelection = codeViewModel.openedFileText.startIndex..<codeViewModel.openedFileText.endIndex
//                }
//            } else {
//                // If scope is anything else return TODO: Handle Errors
//                print("Scope \(scope) is not supported in narrow scope generation!")
//                return
//            }
//            
//            // Ensure authToken
//            let authToken: String
//            do {
//                authToken = try await AuthHelper.ensure()
//            } catch {
//                // TODO: Handle Errors
//                print("Error ensuring authToken in MainView... \(error)")
//                return
//            }
//            
//            // Stream Chat
//            do {
//                try await chatGenerator.streamChat(
//                    authToken: authToken,
//                    model: .GPT4o,
//                    action: actionType,
//                    additionalInput: additionalInput,
//                    language: codeViewModel.openedFileLanguage,
//                    context: context, // TODO: Implement full project context
//                    input: input,
//                    scope: scope)
//            } catch {
//                // TODO: Handle Errors
//                print("Error streaming chat in MainView... \(error)")
//            }
//        }
//    }
    
}

#Preview {
    CodeView(
        codeViewModel: .constant(CodeViewModel(filepath: "~/Downloads/test_dir/testing.txt")),
        hasSelection: .constant(false)
    )
    .environmentObject(ActiveSubscriptionUpdater())
    .environmentObject(UndoUpdater())
}

