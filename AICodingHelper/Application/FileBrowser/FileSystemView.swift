//
//  FileSystemView.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 6/26/24.
//

import Foundation
import SwiftUI

struct FileSystemView: View {
    
    @Binding var directory: String
    @Binding var selectedFile: String?
    
    @StateObject private var fileTree: FileTree
    
    init(directory: Binding<String>, selectedFile: Binding<String?>) {
        self._directory = directory
        self._selectedFile = selectedFile
        _fileTree = StateObject(wrappedValue: FileTree(rootDirectory: directory.wrappedValue))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 2) {
                FileNodeView(node: fileTree.rootNode, level: 0, selectedFile: $selectedFile)
            }
            .padding()
        }
        .onChange(of: directory, perform: { newDirectory in
            fileTree.updateRootDirectory(to: newDirectory)
        })
    }
    
}
