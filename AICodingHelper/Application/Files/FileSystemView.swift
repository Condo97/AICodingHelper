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
    var onAction: (_ action: FileActions, _ path: String) -> Void
    
    @StateObject private var fileTree: FileTree
    @State private var fileMonitor: FileMonitor?
    
    
    init(directory: Binding<String>, selectedFilepaths: Binding<[String]>, onAction: @escaping (_ action: FileActions, _ path: String) -> Void) {
        self._directory = directory
        self._selectedFilepaths = selectedFilepaths
        self.onAction = onAction
        _fileTree = StateObject(wrappedValue: FileTree(rootDirectory: directory.wrappedValue))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    FileNodeView(
                        node: fileTree.rootNode,
                        level: 0,
                        selectedFilepaths: $selectedFilepaths,
                        onAction: onAction
                    )
                    Spacer()
                }
            }
            .padding()
        }
        .onChange(of: directory) { newDirectory in
            fileTree.updateRootDirectory(to: newDirectory)
            startFileMonitor()
        }
        .onReceive(fileTree.$rootNode) { _ in
            removeInvalidFilesFromSelectedFilepaths()
        }
        .onAppear {
            startFileMonitor()
        }
        .onDisappear {
            stopFileMonitor()
        }
    }
    
    private func removeInvalidFilesFromSelectedFilepaths() {
        var allFilePaths = Set<String>()
        collectFilePaths(node: fileTree.rootNode, filePaths: &allFilePaths)
        
        selectedFilepaths = selectedFilepaths.filter { allFilePaths.contains($0) }
    }
    
    private func collectFilePaths(node: FileNode, filePaths: inout Set<String>) {
        filePaths.insert(node.path)
        for child in node.children {
            collectFilePaths(node: child, filePaths: &filePaths)
        }
    }
    
    private func startFileMonitor() {
        stopFileMonitor()
        let expandedPath = NSString(string: directory).expandingTildeInPath
        fileMonitor = FileMonitor(paths: [expandedPath]) {
            fileTree.updateRootDirectory(to: directory)
        }
        fileMonitor?.start()
    }
    
    private func stopFileMonitor() {
        fileMonitor?.stop()
        fileMonitor = nil
    }
    
}
