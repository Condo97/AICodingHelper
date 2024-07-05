//
//  TabsViewModel.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/2/24.
//

import Combine
import Foundation


class TabsViewModel: ObservableObject {
    
    @Published var openTabs: [CodeViewModel] = []
    @Published var openTab: CodeViewModel?
    
    
    func removeTabs(withFilepath filepath: String) {
        // Set openTab to nil if its filepath equals filepath
        if openTab?.filepath == filepath {
            openTab = nil
        }
        
        // Remove all tabs where their filepath equals filepath
        openTabs.removeAll(where: {$0.filepath == filepath})
    }
    
    func saveUndo(undoManager: UndoManager) {
        saveUndo(
            undoManager: undoManager,
            oldOpenTab: openTab)
    }
    
    func saveUndo(undoManager: UndoManager, oldOpenTab: CodeViewModel?) {
        undoManager.registerUndo(withTarget: self) { target in
            let currentOpenTab = target.openTab
            
            target.openTab = oldOpenTab
            
            target.saveUndo(
                undoManager: undoManager,
                oldOpenTab: currentOpenTab)
        }
    }
    
    
}
