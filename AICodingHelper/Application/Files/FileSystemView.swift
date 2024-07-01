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
    @Binding var selectedFilepaths: [String]
    var onOpen: (_ path: String) -> Void
    
    @StateObject private var fileTree: FileTree
    
    init(directory: Binding<String>, selectedFilepaths: Binding<[String]>, onOpen: @escaping (_ path: String) -> Void) {
        self._directory = directory
        self._selectedFilepaths = selectedFilepaths
        self.onOpen = onOpen
        _fileTree = StateObject(wrappedValue: FileTree(rootDirectory: directory.wrappedValue))
    }
    
    var body: some View {
        ScrollView {
            // Refresh Button
            Button(action: { fileTree.updateRootDirectory(to: directory) }) {
                HStack {
//                    Spacer()
                    Text("Refresh")
//                    Spacer()
                }
                .foregroundStyle(Colors.elementText)
                .frame(minWidth: 50.0, maxWidth: .infinity)
                .padding()
                .background(Colors.element)
                .clipShape(RoundedRectangle(cornerRadius: 28.0))
            }
            .buttonStyle(PlainButtonStyle())
            .padding()
            
            // File Nodes
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    FileNodeView(node: fileTree.rootNode, level: 0, selectedFilepaths: $selectedFilepaths, onOpen: onOpen)
                    
                    Spacer()
                }
            }
            .padding()
        }
        .onChange(of: directory, perform: { newDirectory in
            fileTree.updateRootDirectory(to: newDirectory)
        })
    }
    
}
