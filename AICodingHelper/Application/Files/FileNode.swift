//
//  FileNode.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 6/26/24.
//

import Foundation

class FileNode: ObservableObject, Identifiable {
    
    let id = UUID()
    let name: String
    let path: String
    
    @Published var isExpanded: Bool = false
    @Published var children: [FileNode] = []
    
    var isDirectory: Bool {
        var isDir: ObjCBool = false
        FileManager.default.fileExists(atPath: path, isDirectory: &isDir)
        return isDir.boolValue
    }
    
    init(path: String) {
        self.path = path
        self.name = (path as NSString).lastPathComponent
    }
    
    func toggleExpansion() {
        if isDirectory {
            isExpanded.toggle()
            if isExpanded && children.isEmpty {
                discoverChildren()
            }
        }
    }
    
    func discoverChildren() {
        guard isDirectory else { return }
        do {
            let contents = try FileManager.default.contentsOfDirectory(atPath: path)
            children = contents.map { FileNode(path: (self.path as NSString).appendingPathComponent($0)) }
                .sorted { $1.name > $0.name }
                .sorted { $0.isDirectory && !$1.isDirectory }
        } catch {
            print("Error reading contents of directory: \(error)")
        }
    }
    
    func expandedPaths() -> Set<String> {
        var paths = Set<String>()
        if isExpanded {
            paths.insert(path)
            for child in children {
                paths.formUnion(child.expandedPaths())
            }
        }
        return paths
    }
    
    func applyExpandedPaths(_ paths: Set<String>) {
        if paths.contains(path) {
            isExpanded = true
            discoverChildren()
            for child in children {
                child.applyExpandedPaths(paths)
            }
        }
    }
    
}
