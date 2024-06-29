//
//  TabAddingFileSystemView.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 6/29/24.
//

import SwiftUI

struct TabAddingFileSystemView: View {
    
    @Binding var directory: String
    @Binding var selectedPath: String?
    @Binding var openTabs: [CodeViewModel]
    
    
    @State private var openedFile: String?
    
    
    var body: some View {
        
        FileSystemView(
            directory: $directory,
            selectedPath: $selectedPath,
            openedFile: $openedFile)
        .onChange(of: openedFile) {
            // Add to tab if openFile can be unwrapped and is not contained in openTabs where openFile equals the openTab filepath
            if let openedFile = openedFile,
               !openTabs.contains(where: {$0.filepath == openedFile}) {
                openTabs.append(
                    CodeViewModel(filepath: openedFile)
                )
            }
        }
        
    }
    
}

#Preview {
    
    TabAddingFileSystemView(
        directory: .constant(""),
        selectedPath: .constant(""),
        openTabs: .constant([])
    )
    
}
