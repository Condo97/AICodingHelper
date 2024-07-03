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
        // Save the current expanded paths
        let expandedPaths = rootNode.expandedPaths()
        
        // Update the root node
        let expandedPath = NSString(string: newDirectory).expandingTildeInPath
        rootNode = FileNode(path: expandedPath)
        rootNode.discoverChildren()
        
        // Reapply the expanded paths
        rootNode.applyExpandedPaths(expandedPaths)
    }
    
}
