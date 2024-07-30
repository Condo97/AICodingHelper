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
