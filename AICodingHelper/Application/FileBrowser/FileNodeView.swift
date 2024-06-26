//
//  FileNodeView.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 6/26/24.
//

import Foundation
import SwiftUI

struct FileNodeView: View {
    
    @ObservedObject var node: FileNode
    let level: Int
    @Binding var selectedFile: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                if node.isDirectory {
                    Image(systemName: node.isExpanded ? "arrowtriangle.down.fill" : "arrowtriangle.right.fill")
                        .onTapGesture {
                            node.toggleExpansion()
                        }
                        .padding(.trailing, 2)
                } else {
                    Image(systemName: "doc.fill")
                        .foregroundColor(.blue)
                        .padding(.trailing, 2)
                }
                Text(node.name)
                    .onTapGesture {
                        if !node.isDirectory {
                            selectedFile = node.path
                        }
                    }
            }
            .padding(.leading, CGFloat(level) * 15)
            .padding(.vertical, 2)
            
            if node.isExpanded {
                ForEach(node.children) { childNode in
                    FileNodeView(node: childNode, level: level + 1, selectedFile: $selectedFile)
                }
            }
        }
    }
    
}
