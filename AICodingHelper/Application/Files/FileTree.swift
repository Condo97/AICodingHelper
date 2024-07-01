//
//  FileTree.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 6/26/24.
//

import Foundation
import SwiftUI

class FileTree: ObservableObject {
    
    @Published var rootNode: FileNode
    
    init(rootDirectory: String) {
        let expandedPath = NSString(string: rootDirectory).expandingTildeInPath
        rootNode = FileNode(path: expandedPath)
        rootNode.discoverChildren()
    }
    
    func updateRootDirectory(to newDirectory: String) {
        let expandedPath = NSString(string: newDirectory).expandingTildeInPath
        rootNode = FileNode(path: expandedPath)
        rootNode.discoverChildren()
    }
    
}
