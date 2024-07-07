//
//  FileNodeView.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 6/26/24.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct FileNodeView: View {
    
    @ObservedObject var node: FileNode
    let level: Int
    @Binding var selectedFilepaths: [String]
    var onAction: (_ action: FileActions, _ path: String) -> Void
    
    @EnvironmentObject private var focusViewModel: FocusViewModel
    
    @FocusState private var focused
    
    @State private var alertShowingRename = false
    @State private var newName: String = ""
    @State private var showCreateFolderAlert = false
    @State private var showCreateFileAlert = false
    @State private var newEntityName: String = ""
    @State private var showAlertError: Bool = false
    @State private var errorMessage: String = ""

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
                            onAction(.open, node.path)
                        }
                    }
                    .simultaneousGesture(
                        TapGesture(count: 1)
                            .onEnded {
                                if NSEvent.modifierFlags.contains(.shift) {
                                    selectedFilepaths.append(node.path)
                                } else {
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
                ? Colors.element.opacity(selectedFilepaths.contains(node.path) ? 0.3 : 0)
                : Color.gray.opacity(selectedFilepaths.contains(node.path) ? 0.3 : 0)
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
                            do {
                                let directory = node.isDirectory ? node.path : (node.path as NSString).deletingLastPathComponent
                                try FileManager.default.moveItem(atPath: filepath as String, toPath: URL(fileURLWithPath: directory).appendingPathComponent(filepath.lastPathComponent).path)
                            } catch {
                                errorMessage = "Error moving item in FileNodeView... \(error)"
                                showAlertError = true
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
            Button(action: {
                NSWorkspace.shared.activateFileViewerSelecting([URL(fileURLWithPath: node.path)])
            }) {
                Text("Reveal in Finder")
            }
            
            Divider()
            
            Button(action: {
                alertShowingRename = true
            }) {
                Text("Rename")
            }
            
            Divider()
            
            Button(action: {
                showCreateFolderAlert = true
            }) {
                Text("Create Folder")
            }
            
            Button(action: {
                showCreateFileAlert = true
            }) {
                Text("Create File")
            }
            
            Divider()
            
            Button(action: {
                do {
                    try FileManager.default.removeItem(atPath: node.path)
                } catch {
                    errorMessage = "Error deleting item in FileNodeView... \(error)"
                    showAlertError = true
                }
            }) {
                Text("Delete")
            }
        }
        .alert("Rename File", isPresented: $alertShowingRename) {
            TextField("New Name", text: $newName)
            Button("Rename") {
                do {
                    let newPath = URL(fileURLWithPath: (node.path as NSString).deletingLastPathComponent).appendingPathComponent(newName).path
                    try FileManager.default.moveItem(atPath: node.path, toPath: newPath)
                } catch {
                    errorMessage = "Error renaming item in FileNodeView... \(error)"
                    showAlertError = true
                }
            }
            Button("Cancel", role: .cancel) {}
        }
        .alert("Create File", isPresented: $showCreateFileAlert) {
            TextField("File Name", text: $newEntityName)
            Button("Create") {
                createFile(withName: newEntityName, atPath: node.path)
            }
            Button("Cancel", role: .cancel) {}
        }
        .alert("Create Folder", isPresented: $showCreateFolderAlert) {
            TextField("Folder Name", text: $newEntityName)
            Button("Create") {
                createFolder(withName: newEntityName, atPath: node.path)
            }
            Button("Cancel", role: .cancel) {}
        }
        .alert(isPresented: $showAlertError) {
            Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    private func createFolder(withName name: String, atPath path: String) {
        let directoryPath = node.isDirectory ? path : (path as NSString).deletingLastPathComponent
        let folderPath = URL(fileURLWithPath: directoryPath).appendingPathComponent(name).path
        
        if FileManager.default.fileExists(atPath: folderPath) {
            errorMessage = "Folder already exists at path: \(folderPath)"
            showAlertError = true
        } else {
            do {
                try FileManager.default.createDirectory(atPath: folderPath, withIntermediateDirectories: false, attributes: nil)
            } catch {
                errorMessage = "Error creating folder: \(error)"
                showAlertError = true
            }
        }
    }
    
    private func createFile(withName name: String, atPath path: String) {
        let directoryPath = node.isDirectory ? path : (path as NSString).deletingLastPathComponent
        let filePath = URL(fileURLWithPath: directoryPath).appendingPathComponent(name).path
        
        if FileManager.default.fileExists(atPath: filePath) {
            errorMessage = "File already exists at path: \(filePath)"
            showAlertError = true
        } else {
            FileManager.default.createFile(atPath: filePath, contents: nil, attributes: nil)
        }
    }
    
}
