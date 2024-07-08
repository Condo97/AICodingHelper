import Foundation
import SwiftUI

struct AICodingHelperAppCommands: Commands {
    
    @Binding var baseFilepath: String
    @Binding var isShowingNewAIProject: Bool
    @Binding var isShowingNewBlankProject: Bool
    @Binding var isShowingNewAIFilePopup: Bool
    @Binding var isShowingNewBlankFilePopup: Bool
    @Binding var isShowingNewFolderPopup: Bool
    @Binding var isShowingOpenFileImporter: Bool
    
    
    var body: some Commands {
        CommandGroup(replacing: .newItem) {
            Button("New AI Project...", action: {
                isShowingNewAIProject = true
            })
            
            Button("New Blank Project...", action: {
                isShowingNewBlankProject = true
            })
            
            
            if baseFilepath.isEmpty {
                // No Filepath Commands
            } else {
                // File Showing Commands
                Button(action: {
                    isShowingNewAIFilePopup = true
                }) {
                    Text("New AI File...")
                }
                .keyboardShortcut("N", modifiers: .command)
                
                Button("New Blank File...") {
                    isShowingNewBlankFilePopup = true
                }
                .keyboardShortcut("N", modifiers: [.shift, .command])
                
                Button("New Folder...") {
                    isShowingNewFolderPopup = true
                }
                .keyboardShortcut("N", modifiers: [.shift, .command, .option])
                
                Divider()
                
                Button("Open Folder...") {
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
