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
    @Binding var searchText: String
    var onAction: (_ action: FileActions, _ path: String) -> Void
    
    @EnvironmentObject private var focusViewModel: FocusViewModel
    
    @StateObject private var fileTree: FileTree
    @State private var fileMonitor: FileMonitor?
    @State private var searchResults: [String] = [] // State variable to hold search results
    
    
    init(directory: Binding<String>, selectedFilepaths: Binding<[String]>, searchText: Binding<String>, onAction: @escaping (_ action: FileActions, _ path: String) -> Void) {
        self._directory = directory
        self._selectedFilepaths = selectedFilepaths
        self._searchText = searchText
        self.onAction = onAction
        _fileTree = StateObject(wrappedValue: FileTree(rootDirectory: directory.wrappedValue))
    }
    
    var body: some View {
        ScrollView {
            if searchText.isEmpty {
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
                .padding(.horizontal)
            } else {
                VStack(spacing: 0.0) {
                    ForEach($searchResults, id: \.self) { resultFilepath in
                        SearchResultFileNodeView(
                            filepath: resultFilepath,
                            selectedFilepaths: $selectedFilepaths,
                            onAction: onAction)
                        Divider()
                    }
                }
            }
        }
        .onChange(of: directory) { newDirectory in
            fileTree.updateRootDirectory(to: newDirectory)
            startFileMonitor()
        }
        .onChange(of: searchText) { newValue in
            performSearch(query: newValue)
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
    
    private func performSearch(query: String) {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        let fileManager = FileManager.default
        let baseDirectoryURL = URL(fileURLWithPath: directory)
        
        var results: [String] = []
        
        if let enumerator = fileManager.enumerator(at: baseDirectoryURL, includingPropertiesForKeys: nil) {
            for case let url as URL in enumerator {
                if !url.hasDirectoryPath && url.lastPathComponent.contains(query) {
                    results.append(url.path)
                }
            }
        }
        
        searchResults = results
    }
    
}
