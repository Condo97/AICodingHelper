import Foundation
import SwiftUI

struct AICodingHelperAppCommands: Commands {
    
    @State var availableCommands: AvailableCommands
    @Binding var isShowingNewAIProject: Bool
    @Binding var isShowingNewBlankProject: Bool
    @Binding var isShowingNewAIFilePopup: Bool
    @Binding var isShowingNewBlankFilePopup: Bool
    @Binding var isShowingNewFolderPopup: Bool
    @Binding var isShowingOpenFileImporter: Bool
    
    
    var body: some Commands {
        CommandGroup(replacing: .newItem) {
            if availableCommands.contains(.newAIProject) {
                Button("New AI Project...", action: {
                    isShowingNewAIProject = true
                })
            }
            
            if availableCommands.contains(.newBlankProject) {
                Button("New Blank Project...", action: {
                    isShowingNewBlankProject = true
                })
            }
            
            if availableCommands.contains(.newAIFile) {
                Button(action: {
                    isShowingNewAIFilePopup = true
                }) {
                    Text("New AI File...")
                }
                .keyboardShortcut("N", modifiers: .command)
            }
            
            if availableCommands.contains(.newBlankFile) {
                Button("New Blank File...") {
                    isShowingNewBlankFilePopup = true
                }
                .keyboardShortcut("N", modifiers: [.shift, .command])
            }
            
            if availableCommands.contains(.newFolder) {
                Button("New Folder...") {
                    isShowingNewFolderPopup = true
                }
                .keyboardShortcut("N", modifiers: [.shift, .command, .option])
            }
            
            Divider()
            
            if availableCommands.contains(.openProject) {
                Button("Open Project...") {
                    isShowingOpenFileImporter = true
                }
                .keyboardShortcut("O", modifiers: [.command])
            }
        }
        
//        CommandMenu("Custom Menu") {
//            Button(action: {
//                // Custom Action
//            }) {
//                Text("Custom Command 1")
//            }
//            .keyboardShortcut("1", modifiers: .command)
//            
//            Button(action: {
//                // Another Custom Action
//            }) {
//                Text("Custom Command 2")
//            }
//            .keyboardShortcut("2", modifiers: .command)
//        }
    }
    
}
