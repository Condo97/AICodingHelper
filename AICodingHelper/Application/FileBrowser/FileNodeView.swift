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
    @Binding var selectedPath: String?
    @Binding var openedFile: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                if node.isDirectory {
                    Image(systemName: node.isExpanded ? "arrowtriangle.down.fill" : "arrowtriangle.right.fill")
                        .padding(.trailing, 2)
                        .onTapGesture {
                            node.toggleExpansion()
                        }
                } else {
                    Image(systemName: "doc.fill")
                        .foregroundColor(.blue)
                        .padding(.trailing, 2)
                }
                
                Text(node.name)
                    .onTapGesture(count: 2) {
                        if node.isDirectory {
                            node.toggleExpansion()
                        } else {
                            openedFile = node.path
                        }
                    }
                    .simultaneousGesture(
                        TapGesture(count: 1)
                            .onEnded {
                                selectedPath = node.path
                            }
                    )
            }
            .padding(.leading, CGFloat(level) * 15)
            .padding(.vertical, 2)
            .background(Color.gray.opacity(selectedPath == node.path ? 0.3 : 0))
            .cornerRadius(5)
            
            if node.isExpanded {
                ForEach(node.children) { childNode in
                    FileNodeView(node: childNode, level: level + 1, selectedPath: $selectedPath, openedFile: $openedFile)
                }
            }
        }
    }
    
}
