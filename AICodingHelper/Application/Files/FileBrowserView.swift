//
//  FileBrowserView.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/1/24.
//

import SwiftUI

struct FileBrowserView: View {
    
    @Binding var baseDirectory: String
    @Binding var selectedFilepaths: [String]
    @ObservedObject var tabsViewModel: TabsViewModel
    
    
//    @State private var currentWideScope: Scope?
    
    
    var body: some View {
        ZStack {
            // File Browser
            TabAddingFileSystemView(
                directory: $baseDirectory,
                selectedFilepaths: $selectedFilepaths,
                tabsViewModel: tabsViewModel)
        }
    }
    
}

#Preview {
    
    FileBrowserView(
        baseDirectory: .constant("~/Downloads/test_dir"),
        selectedFilepaths: .constant([]),
        tabsViewModel: TabsViewModel())
    
}
