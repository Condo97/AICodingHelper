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
                .sorted { $0.isDirectory && !$1.isDirectory }
        } catch {
            print("Error reading contents of directory: \(error)")
        }
    }
    
}
