//
//  CodeViewModel.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 6/28/24.
//

import CommonCrypto
import CodeEditor
import Foundation
import SwiftUI

class CodeViewModel: ObservableObject, Identifiable {
    
    @Published var filepath: String? {
        didSet {
            startFileMonitoring()
        }
    }
    @Published var openedFileText: String = "" {
        didSet {
            if let filepath = filepath {
                do {
                    try openedFileText.write(toFile: filepath, atomically: true, encoding: .utf8)
                } catch {
                    print("Error writing to file in CodeViewModel... \(error)")
                }
            }
        }
    }
    @Published var openedFileTextSelection: Range<String.Index> = "".startIndex..<"".endIndex
    
    @Published var openedFileLanguage: CodeEditor.Language?
    
    @Published var narrowScopeStreamGenerationInitialSelection: Range<String.Index>?
    @Published var narrowScopeStreamGenerationCursorPosition: String.Index?
    
    @Published var invalidOpenAIKey: Bool = false
    
    @Published var isLoading: Bool = false
    @Published var isStreaming: Bool = false
    
    
    private let additionalTokensForEstimation: Int = Constants.Additional.additionalTokensForEstimationPerFile
    
    
    private var fileMonitor: FileMonitor?
    private var lastFileHash: String?
    
    
    init(filepath: String?) {
        self.filepath = filepath
    }
    
    func saveUndo(undoManager: UndoManager) {
        let oldFileText = openedFileText
        let oldFileTextSelection = openedFileTextSelection
        saveUndo(
            undoManager: undoManager,
            oldFileText: oldFileText,
            oldFileTextSelection: oldFileTextSelection)
    }
    
    func saveUndo(undoManager: UndoManager, oldFileText: String, oldFileTextSelection: Range<String.Index>) {
        // Save text edit undo action, on FileManager or something we will save a file change undo action
        undoManager.registerUndo(withTarget: self) { target in
            let currentText = target.openedFileText
            let currentTextSelection = target.openedFileTextSelection
            
            target.openedFileText = oldFileText
            target.openedFileTextSelection = oldFileTextSelection
            
            target.saveUndo(undoManager: undoManager, oldFileText: currentText, oldFileTextSelection: currentTextSelection)
        }
    }
    
    func startFileMonitoring() {
        guard let filepath = filepath else {
            fileMonitor?.stop()
            fileMonitor = nil
            return
        }
        
        fileMonitor = FileMonitor(paths: [filepath]) { [weak self] in
            DispatchQueue.main.async {
                // TODO: There is more optimization to be done here. Right now if a change is made to the file, it saves the file, then updates it here which causes it to reload which causes it to save which causes it to reload etc. This does not happen with the lastFileHash since it stops the updating and saving of the file if the content is the same which does not cause a view refresh and the save action to restart this loop. However right now what *is* going on is when I update the file text in app it saves the update and then calls reloadFileContents, is this fine? Is there something to optimze here? That's sorta what I'm saying there is lol
                self?.reloadFileContents()
            }
        }
        fileMonitor?.start()
        reloadFileContents()
    }
    
    @MainActor // What does this do? It seems to silence the undoManager data race beacuse of not using a main actor isolated context but what is it actually doing
    func generate(authToken: String, openAIKey: String?, remainingTokens: Int, action: ActionType, additionalInput: String?, scope: Scope, context: [String], undoManager: UndoManager?, options: GenerateOptions) async {
        // Defer setting isLoading and isStreaming to false
        defer {
            DispatchQueue.main.async {
                self.isLoading = false
                self.isStreaming = false
            }
        }
        
        // Set isLoading to true
        await MainActor.run {
            isLoading = true
        }
        
        // Create mutable context variable
        var mutableContext = context
        
        // Get input for scope
        let input: String = {
            let selectionPrefix = "THE SELECTION TO MODIFY:\n"
            
            // If scope is highlight and highlighted text is valid set input to highlight
            if scope == .highlight && openedFileTextSelection.lowerBound >= openedFileText.startIndex && openedFileTextSelection.upperBound <= openedFileText.endIndex {
                return selectionPrefix + String(openedFileText[openedFileTextSelection])
            }
            
            // Otherwise set to openedFileText
            return selectionPrefix + openedFileText
        }()
        
        // If scope is highlight and highlighted text is valid add opened file text to context
        if scope == .highlight && openedFileTextSelection.lowerBound >= openedFileText.startIndex && openedFileTextSelection.upperBound <= openedFileText.endIndex {
            mutableContext.append("This is the entire file for which you are to process a selection of. IMPORTANT: Respond as if you are replacing exactly the selection provided.\n\n\(openedFileText)")
        }
        
        // If scope is highlight and highlihgted text is valid set narrowScopeStreamGenerationInitialSelection to openedFileTextSelection otherwise the entire file
        if scope == .highlight && openedFileTextSelection.lowerBound >= openedFileText.startIndex && openedFileTextSelection.upperBound <= openedFileText.endIndex {
            narrowScopeStreamGenerationInitialSelection = openedFileTextSelection
        } else {
            narrowScopeStreamGenerationInitialSelection = openedFileText.startIndex..<openedFileText.endIndex
        }
        
        // TODO: Include entire project in context generate option implemetation
        
        // If no openAIKey, calculate tokens with action, input, context, and additionalInput to ensure it is within user's remaining tokens, otherwise throw estimatedTokensHitsLimit error
        if openAIKey == nil || openAIKey!.isEmpty {
            do {
                let estimatedTokens = try await TokenCalculator.calculateTokens(
                    authToken: authToken,
                    inputs: [
                        action.aiPrompt,
                        input,
                    ] + context + [
                        additionalInput ?? ""
                    ]
                )
                
                if estimatedTokens + additionalTokensForEstimation > remainingTokens {
                    throw GenerationError.estimatedTokensHitsLimit
                }
            } catch {
                // TODO: Handle Errors
                print("Error estimating tokens in CodeViewModel... \(error)")
                return
            }
        }
        
        // Do generation
        do {
            var firstChat = true
            try await ChatGenerator.streamChat(
                authToken: authToken,
                openAIKey: openAIKey,
                model: .GPT4o,
                action: action,
                additionalInput: additionalInput,
                language: openedFileLanguage,
                responseFormat: .text,
                context: mutableContext,
                input: input,
                stream: { getChatResponse in
                    if firstChat {
                        // Set isLoading to false and isStreaming to true
                        await MainActor.run {
                            isLoading = false
                            isStreaming = true
                            
                        }
                        
                        // Save undo
                        if let undoManager = undoManager {
                            saveUndo(undoManager: undoManager)
                        }
                        
                        // If scope is highlight and highlighted text is valid do highilghted scope operations, otherwise do file wide operations
                        if scope == .highlight && openedFileTextSelection.lowerBound >= openedFileText.startIndex && openedFileTextSelection.upperBound <= openedFileText.endIndex,
                           let narrowScopeStreamGenerationInitialSelection = narrowScopeStreamGenerationInitialSelection {
                            await MainActor.run {
                                // Delete narrowScopeStreamGenerationInitialSelection subrange, set narrowScopeStreamGenerationCursorPosition to narrowScopeStreamGenerationInitialSelection lowerBound, and set openedFileTextSelection to a range from narrowScopeStreamGenerationCursorPosition to narrowScopeStreamGenerationCursorPosition
                                openedFileText.replaceSubrange(narrowScopeStreamGenerationInitialSelection, with: "")
                                
                                narrowScopeStreamGenerationCursorPosition = narrowScopeStreamGenerationInitialSelection.lowerBound
                                
                                openedFileTextSelection = narrowScopeStreamGenerationCursorPosition!..<narrowScopeStreamGenerationCursorPosition!
                            }
                        } else {
                            await MainActor.run {
                                // If generate option copyCurrentFilesToTempFiles is true and filepath can be unwrapped copy file to temp file
                                if options.contains(.copyCurrentFilesToTempFiles),
                                   let filepath = filepath {
                                    do {
                                        try FileCopier.copyFileToTempVersion(at: filepath)
                                    } catch {
                                        // TODO: Handle Errors
                                        print("Error copying current file to temp file in CodeViewModel, proceeding... \(error)")
                                    }
                                }
                                
                                // Set openedFileText to empty string
                                openedFileText = ""
                                
                                // Set narrowScopeStreamGenerationCursorPosition to openedFileText startIndex
                                narrowScopeStreamGenerationCursorPosition = openedFileText.startIndex
                                
                                // Set openedFileTextSelection to range from narrowScopeStreamGenerationCursorPosition to narrowScopeStreamGenerationCursorPosition
                                openedFileTextSelection = narrowScopeStreamGenerationCursorPosition!..<narrowScopeStreamGenerationCursorPosition!
                            }
                        }
                        // Set firstChat to false
                        firstChat = false
                    }
                    
                    // Update with streaming chat delta
                    if let chatTextDelta = getChatResponse.body.oaiResponse.choices[safe: 0]?.delta.content {
                        await MainActor.run {
                            // Insert newValue at narrowScopeStreamGenerationCursorPosition or if null startIndex
                            openedFileText.insert(contentsOf: chatTextDelta, at: narrowScopeStreamGenerationCursorPosition ?? openedFileText.startIndex)
                            
                            // Set narrowScopeStreamGenerationCursorPosition to itself offset by newValue count
                            narrowScopeStreamGenerationCursorPosition = openedFileText.index(narrowScopeStreamGenerationCursorPosition ?? openedFileText.startIndex, offsetBy: chatTextDelta.count)
                            
                            // Set openedFileTextSelection to range from narrowScopeStreamGenerationCursorPosition to narrowScopeStreamGenerationCursorPosition
                            if let narrowScopeStreamGenerationCursorPosition = narrowScopeStreamGenerationCursorPosition {
                                openedFileTextSelection = narrowScopeStreamGenerationCursorPosition..<narrowScopeStreamGenerationCursorPosition
                            }
                        }
                    }
                })
        } catch GenerationError.invalidOpenAIKey {
            invalidOpenAIKey = true
        } catch {
            print("Error streaming chat in CodeViewModel... \(error)")
        }
        
    }
    
    
    private func reloadFileContents() {
        guard let filepath = filepath else { return }
        do {
            let fileText = try String(contentsOfFile: filepath)
            let newFileHash = hashString(fileText)
            
            if newFileHash != lastFileHash { // TODO: See when I update the text file in app it calls this which does update the lastFileHash which is good but it would be nicer if it was already updated coming in to this, because right now there are two updates happening to fileText because it goes Edit in App -> Text Change Detected -> Save Text -> File Change Detected here -> Reload File Contents, Update OpenedFileText and LastFileHash -> Text Change Detected -> Save Text -> File Change Detected here -X newFileHash == lastFileHash so it drops off.. But this could be simpler!
                // Set openedFilexText to fileText
                self.openedFileText = fileText
                
                // Set openedFileLanguage to language for file extension
                let filepathURL = URL(fileURLWithPath: filepath)
                let fileExtension = filepathURL.pathExtension
                self.openedFileLanguage = CodeEditorLanguageResolver.language(for: fileExtension)
                
                // Set lastFileHash to newFileHash
                self.lastFileHash = newFileHash
            }
        } catch {
            print("Error getting contents of file in CodeViewModel... \(error)")
        }
    }

    private func hashString(_ str: String) -> String {
        let data = Data(str.utf8)
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
        }
        return hash.map { String(format: "%02x", $0) }.joined()
    }
    
    
}
