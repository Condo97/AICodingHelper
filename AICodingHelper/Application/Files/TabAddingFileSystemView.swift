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
    @Binding var openTab: CodeViewModel?
    @Binding var openTabs: [CodeViewModel]
    
    
    @State private var openedFile: String?
    
    
    var body: some View {
        
        FileSystemView(
            directory: $directory,
            selectedFilepaths: $selectedFilepaths,
            onOpen: { path in
                // Append to openTabs if not in there
                if !openTabs.contains(where: {$0.filepath == path}) {
                    openTabs.append(
                        CodeViewModel(filepath: path)
                    )
                }
                
                // Set openTab to CodeViewModel where filepath is equal to path
                if let pathTab = openTabs.first(where: {$0.filepath == path}) {
                    openTab = pathTab
                }
            })
        
    }
    
}

#Preview {
    
    TabAddingFileSystemView(
        directory: .constant(""),
        selectedFilepaths: .constant([]),
        openTab: .constant(nil),
        openTabs: .constant([])
    )
    
}
