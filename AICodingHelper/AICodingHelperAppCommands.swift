import SwiftUI

struct AICodingHelperAppCommands: Commands {
    
    @Binding var baseFilepath: String
    
    
    @State private var isShowingNewAIFilePopup: Bool = false
    @State private var isShowingNewBlankFilePopup: Bool = false
    @State private var isShowingNewFolderPopup: Bool = false
    
    var body: some Commands {
        CommandGroup(replacing: .newItem) {
            Button(action: {
                isShowingNewAIFilePopup = true
            }) {
                Text("New AI File...")
            }
            .keyboardShortcut("N", modifiers: .command)
            .aiFileCreatorPopup(
                isPresented: $isShowingNewAIFilePopup,
                baseFilepath: baseFilepath,
                referenceFilepaths: [])
            
            Button("New Blank File...") {
                isShowingNewBlankFilePopup = true
            }
            .keyboardShortcut("N", modifiers: [.shift, .command])
        }
        
        CommandGroup(after: .newItem) {
            Button("New Folder...") {
                isShowingNewFolderPopup = true
            }
            .keyboardShortcut("N", modifiers: [.shift, .command, .option])
        }
        
        CommandGroup(before: .saveItem) {
            Button(action: {
                // Save File Action
            }) {
                Text("Save As...")
            }
            .keyboardShortcut("S", modifiers: [.command, .shift])
        }
        
        CommandMenu("Custom Menu") {
            Button(action: {
                // Custom Action
            }) {
                Text("Custom Command 1")
            }
            .keyboardShortcut("1", modifiers: .command)
            
            Button(action: {
                // Another Custom Action
            }) {
                Text("Custom Command 2")
            }
            .keyboardShortcut("2", modifiers: .command)
        }
    }
    
}
