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
    
    
    @State private var searchText: String = ""
    
    
    var body: some View {
        VStack(spacing: 0.0) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                TextField("Search", text: $searchText)
                    .textFieldStyle(.plain)
            }
            .padding()
            .background(Color.foreground)
            
            // File Browser
            TabAddingFileSystemView(
                directory: $baseDirectory,
                selectedFilepaths: $selectedFilepaths,
                searchText: $searchText,
                tabsViewModel: tabsViewModel)
        }
    }
    
}

#Preview {
    
    FileBrowserView(
        baseDirectory: .constant("~/Downloads/test_dir"),
        selectedFilepaths: .constant([]),
        tabsViewModel: TabsViewModel())
    .environmentObject(FocusViewModel())
    
}
