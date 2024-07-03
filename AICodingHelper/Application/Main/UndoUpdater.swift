//
//  UndoUpdater.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/2/24.
//

import Foundation


class UndoUpdater: ObservableObject {
    
    struct UndoModel {
        
        let filepath: String
        let text: String
        let selection: Range<String.Index>
        
    }
    
    // Watch for updates on nextUndo, as this will be updated every time undo is called
    @Published var currentUndo: UndoModel?
    @Published var mostRecentLoadedUndo: UndoModel?
    
//    private var undoStack: [UndoModel] = [] // [oldest, ..., newest]
//    private var redoStack: [UndoModel] = [] // [most redoed, ..., least redoed which is the current undo since this is only added to if the user performs an undo]
    
    // Save undo state
    func saveUndo(undoManager: UndoManager?, oldUndoModel: UndoModel, newUndoModel: UndoModel) {
        mostRecentLoadedUndo = newUndoModel
        undoManager?.registerUndo(withTarget: self) { target in
            // Set currentUndo to oldUndoModel
            self.currentUndo = oldUndoModel
            
            // Save redo by saving undo with oldUndoModel as newUndoModel and newUndoModel as oldUndoModel
            self.saveUndo(undoManager: undoManager, oldUndoModel: newUndoModel, newUndoModel: oldUndoModel)
        }
    }
    
}
