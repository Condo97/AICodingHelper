//
//  FileNodeView.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 6/26/24.
//

import Foundation
import SwiftUI


// TODO: ContextMenu for cut, copy, paste, and generate stuff
struct FileNodeView: View {
    
    @ObservedObject var node: FileNode
    let level: Int
    @Binding var selectedFilepaths: [String]
    var onAction: (_ action: FileActions, _ path: String) -> Void
    
    
    @EnvironmentObject private var focusViewModel: FocusViewModel
    
    @FocusState private var focused
    
    @State private var alertShowingRename = false
    @State private var newName: String = ""
    
    
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
                            // Expand node
                            node.toggleExpansion()
                        } else {
                            // Open action
                            onAction(.open, node.path)
                        }
                    }
                    .simultaneousGesture(
                        TapGesture(count: 1)
                            .onEnded {
                                if NSEvent.modifierFlags.contains(.shift) {
                                    // If shift is being held append node path to selectedFilepaths
                                    selectedFilepaths.append(node.path)
                                } else {
                                    // Otherwise set selectedFilepaths to node path
                                    selectedFilepaths = [node.path]
                                }
                            }
                    )
                
                Spacer()
            }
            .padding(.leading, CGFloat(level) * 15)
            .padding(.vertical, 2)
            .background(
                focused
                ?
                Colors.element.opacity(selectedFilepaths.contains(node.path) ? 0.3 : 0)
                :
                Color.gray.opacity(selectedFilepaths.contains(node.path) ? 0.3 : 0)
            )
            .cornerRadius(5)
            .focusable()
            .focusEffectDisabledVersionCheck()
            .focused($focused)
            .onChange(of: focused) { newValue in
                if newValue {
                    focusViewModel.focus = .browser
                }
            }
            
            if node.isExpanded {
                ForEach(node.children) { childNode in
                    FileNodeView(node: childNode, level: level + 1, selectedFilepaths: $selectedFilepaths, onAction: onAction)
                }
            }
        }
        .contextMenu {
            // Rename File
            Button(action: {
                onAction(.rename, node.path)
            }) {
                Text("Rename")
            }

            // Create Folder
            Button(action: {
                onAction(.newFolder, node.path)
            }) {
                Text("Create Folder")
            }
            
            // Delete
            Button(action: {
                onAction(.delete, node.path)
            }) {
                Text("Delete")
            }
        }
        
    }
    
}

