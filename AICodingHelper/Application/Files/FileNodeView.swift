//
//  FileNodeView.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 6/26/24.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

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
            .onDrag { NSItemProvider(object: NSString(string: node.path)) }
            .onDrop(of: [.text], isTargeted: nil) { providers in
                if let provider = providers.first {
                    provider.loadObject(ofClass: NSString.self, completionHandler: { providerReading, error in
                        if let filepath = providerReading as? NSString {
                            // If current node is directory move to that directory if not move to the directory the file is in.. The other item is dragged to this node so filepath is the other item and node.path is this node, so move the other filepath to this node's path
                            do {
                                let directory = node.isDirectory ? node.path : (node.path as NSString).deletingLastPathComponent
                                try FileManager.default.moveItem(atPath: filepath as String, toPath: URL(fileURLWithPath: directory).appendingPathComponent(filepath.lastPathComponent, conformingTo: .text).path)
                            } catch {
                                // TODO: Handle Errors
                                print("Error moving item in FileNodeView... \(error)")
                                return
                            }
                        }
                    })
                    
                }
                
                return true
            }
            
            if node.isExpanded {
                ForEach(node.children) { childNode in
                    FileNodeView(node: childNode, level: level + 1, selectedFilepaths: $selectedFilepaths, onAction: onAction)
                }
            }
        }
        .contextMenu {
            // Reveal in Finder
            Button(action: {
                NSWorkspace.shared.activateFileViewerSelecting([URL(fileURLWithPath: node.path)])
            }) {
                Text("Reveal in Finder")
            }
            
            Divider()
            
            // Rename File
            Button(action: {
                onAction(.rename, node.path)
            }) {
                Text("Rename")
            }
            
            Divider()
            
            // Create Folder
            Button(action: {
                onAction(.newFolder, node.path)
            }) {
                Text("Create Folder")
            }
            
            // Create File TODO: Add this
            
            Divider()
            
            // Delete
            Button(action: {
                onAction(.delete, node.path)
            }) {
                Text("Delete")
            }
        }
        
    }
    
}
