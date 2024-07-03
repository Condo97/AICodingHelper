//
//  TabAddingFileSystemView.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 6/29/24.
//

import SwiftUI

struct TabAddingFileSystemView: View {
    
    @Binding var directory: String
    @Binding var selectedFilepaths: [String]
    @ObservedObject var tabsViewModel: TabsViewModel
    
    
    @Environment(\.undoManager) var undoManager
    
    
    @State private var openedFile: String?
    
    
    var body: some View {
        
        FileSystemView(
            directory: $directory,
            selectedFilepaths: $selectedFilepaths,
            onOpen: { path in
                // Append to openTabs if not in there
                if !tabsViewModel.openTabs.contains(where: {$0.filepath == path}) {
                    tabsViewModel.openTabs.append(
                        CodeViewModel(filepath: path)
                    )
                }
                
                // Save undo and set openTab to CodeViewModel where filepath is equal to path
                if let pathTab = tabsViewModel.openTabs.first(where: {$0.filepath == path}) {
                    // Save undo with tabsViewModel openTab before setting it to pathTab
                    if let undoManager = undoManager {
                        tabsViewModel.saveUndo(undoManager: undoManager)
                    }
                    
                    // Set openTab to pathTab
                    tabsViewModel.openTab = pathTab
                }
            })
        
    }
    
}

#Preview {
    
    TabAddingFileSystemView(
        directory: .constant(""),
        selectedFilepaths: .constant([]),
        tabsViewModel: TabsViewModel()
    )
    
}
