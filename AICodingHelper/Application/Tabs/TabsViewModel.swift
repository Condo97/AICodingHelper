//
//  TabsViewModel.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/2/24.
//

import Foundation


class TabsViewModel: ObservableObject {
    
    @Published var openTabs: [CodeViewModel] = []
    @Published var openTab: CodeViewModel?
    
    
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
