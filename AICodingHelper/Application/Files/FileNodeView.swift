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
    @State private var popupShowingCreateAIFile = false
    @State private var popupShowingCreateBlankFile = false
    @State private var popupShowingCreateFolder = false
    @State private var newEntityName: String = ""
    @State private var showAlertError: Bool = false
    @State private var errorMessage: String = ""
    @State private var hovering: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                if node.isDirectory {
                    HStack(spacing: 0.0) {
                        Image(systemName: node.isExpanded ? "arrowtriangle.down.fill" : "arrowtriangle.right")
                            .imageScale(.small)
                        Image(systemName: node.isExpanded ? "folder" : "folder")
                    }
                } else {
                    Image(systemName: "doc.text")
//                        .foregroundColor(.blue)
                }
                
                Text(node.name)
                
                Spacer()
            }
            .padding(.leading, CGFloat(level) * 15)
            .padding(.vertical, 3)
            .background(
                focusViewModel.focus == .browser
                ? Colors.element.opacity(selectedFilepaths.contains(node.path) ? 0.3 : hovering ? 0.1 : 0)
                : Color.gray.opacity(selectedFilepaths.contains(node.path) ? 0.3 : hovering ? 0.1 : 0)
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
            .onHover { hovering in
                self.hovering = hovering
                
                if hovering {
                    NSCursor.arrow.push()
                    NSCursor.pointingHand.set()
                }
            }
//            .background(
//                Rectangle()
//                    .fill(Color.clear)
//                    .onHover { hovering in
//                        if hovering {
//                            Color.lightGray
//                        }
//                }
//            )
            
            if node.isExpanded {
                ForEach(node.children) { childNode in
                    FileNodeView(node: childNode, level: level + 1, selectedFilepaths: $selectedFilepaths, onAction: onAction)
                }
            }
        }
        .contextMenu {
            Button("New AI File...", action: {
                popupShowingCreateAIFile = true
            })
            
            Divider()
            
            Button("New Blank File...", action: {
                popupShowingCreateBlankFile = true
            })
            
            Button("New Folder...", action: {
                popupShowingCreateFolder = true
            })
            
            Divider()
            
            Button("Reveal in Finder", action: {
                NSWorkspace.shared.activateFileViewerSelecting([URL(fileURLWithPath: node.path)])
            })
            
            Divider()
            
            Button("Rename", action: {
                alertShowingRename = true
            })
            
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
        .aiFileCreatorPopup(
            isPresented: $popupShowingCreateAIFile,
            rootFilepath: node.isDirectory ? node.path : URL(fileURLWithPath: node.path).deletingLastPathComponent().path,
            referenceFilepaths: selectedFilepaths)
        .blankFileCreatorPopup(isPresented: $popupShowingCreateBlankFile, path: node.path)
        .folderCreatorPopup(isPresented: $popupShowingCreateFolder, path: node.path)
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
    }
    
}

