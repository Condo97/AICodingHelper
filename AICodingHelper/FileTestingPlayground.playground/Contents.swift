import SwiftUI
import Combine
import PlaygroundSupport
import Foundation

// MARK: - Models and View Models
class FileTree: ObservableObject {
    @Published var rootNode: FileNode
    
    init(rootDirectory: String) {
        let expandedPath = NSString(string: rootDirectory).expandingTildeInPath
        rootNode = FileNode(path: expandedPath)
        rootNode.discoverChildren()
    }
}

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

// MARK: - Views
struct FileSystemView: View {
    @StateObject private var fileTree: FileTree
    
    init(directory: String) {
        _fileTree = StateObject(wrappedValue: FileTree(rootDirectory: directory))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 2) {
                FileNodeView(node: fileTree.rootNode, level: 0)
            }
            .padding()
        }
        .frame(minWidth: 200, minHeight: 400)
    }
}

struct FileNodeView: View {
    @ObservedObject var node: FileNode
    let level: Int
    
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
            }
            .padding(.leading, CGFloat(level) * 15)
            .padding(.vertical, 2)
            
            if node.isExpanded {
                ForEach(node.children) { childNode in
                    FileNodeView(node: childNode, level: level + 1)
                }
            }
        }
    }
}

// MARK: - Entry Point
struct ContentView: View {
    var body: some View {
        // Make sure to replace this path with the desired directory path
        FileSystemView(directory: "~/Downloads/test_dir")
    }
}

// MARK: - Set up for Playground
PlaygroundPage.current.setLiveView(ContentView())
