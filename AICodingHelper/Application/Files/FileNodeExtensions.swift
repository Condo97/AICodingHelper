import SwiftUI

// Added import for Combine
import Combine

struct TabAddingFileSystemView: View {
    
    @Binding var directory: String
    @Binding var selectedFilepaths: [String]
    @Binding var searchText: String
    @ObservedObject var tabsViewModel: TabsViewModel

    @Environment(\.undoManager) var undoManager
    @EnvironmentObject var focusViewModel: FocusViewModel
    
    @State private var alertShowingRenameFile: Bool = false
    @State private var renameFileOriginalPath: String = ""
    @State private var renameFileNewName: String = ""
    
    @State private var alertShowingAddFolder: Bool = false
    @State private var alertShowingErrorAddingFolderFolderExists: Bool = false
    @State private var folderBasePath: String = ""
    @State private var folderName: String = ""

    @State private var cancellable: AnyCancellable?

    var filteredFiles: [String] {
        if searchText.isEmpty {
            return getAllFiles(atPath: directory)
        } else {
            return getAllFiles(atPath: directory).filter { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        List(filteredFiles, id: \.self) { path in
            FileNodeView(
                filePath: path,
                selectedFilepaths: $selectedFilepaths,
                onAction: { action, path in
                    switch action {
                    case .open:
                        // Append to openTabs if not in there
                        if !tabsViewModel.openTabs.contains(where: { $0.filepath == path }) {
                            tabsViewModel.openTabs.append(CodeViewModel(filepath: path))
                        }
                        
                        // Save undo and set openTab to CodeViewModel where filepath is equal to path
                        if let pathTab = tabsViewModel.openTabs.first(where: { $0.filepath == path }) {
                            // Save undo with tabsViewModel openTab before setting it to pathTab
                            if let undoManager = undoManager {
                                tabsViewModel.saveUndo(undoManager: undoManager)
                            }
                            
                            // Set openTab to pathTab
                            tabsViewModel.openTab = pathTab
                            
                            // Set focus to editor
                            focusViewModel.focus = .editor
                        }
                    case .rename:
                        renameFileNewName = URL(fileURLWithPath: path).lastPathComponent
                        renameFileOriginalPath = path
                        alertShowingRenameFile = true
                    case .newFolder:
                        folderName = ""
                        folderBasePath = path
                        alertShowingAddFolder = true
                    case .delete:
                        do {
                            try FileManager.default.removeItem(atPath: path)
                        } catch {
                            // TODO: Handle Errors
                            print("Error deleting file in FileNodeView... \(error)")
                        }
                    }
                }
            )
        }
        .alert("Rename \(renameFileNewName)", isPresented: $alertShowingRenameFile, actions: {
            TextField("New name", text: $renameFileNewName)
            Button("Cancel", role: .cancel, action: {})
            Button("Rename", role: .none, action: {
                let newPath = (renameFileOriginalPath as NSString).deletingLastPathComponent + "/" + renameFileNewName
                do {
                    // Move to newPath
                    try FileManager.default.moveItem(atPath: renameFileOriginalPath, toPath: newPath)
                    
                    // Delete original path
                    tabsViewModel.removeTabs(withFilepath: renameFileOriginalPath)
                } catch {
                    // TODO: Handle Errors
                    print("Error renaming file in FileNodeView... \(error)")
                }
            })
        })
        .alert("Add Folder", isPresented: $alertShowingAddFolder, actions: {
            TextField("Folder Name", text: $folderName)
            Button("Cancel", role: .cancel, action: {})
            Button("Create", role: .none, action: {
                // If file exists for name show error alert and return
                if FileManager.default.fileExists(atPath: (folderBasePath as NSString).appendingPathComponent(folderName)) {
                    self.alertShowingErrorAddingFolderFolderExists = true
                    return
                }
                
                // Create folder
                let newFolderPath = (folderBasePath as NSString).appendingPathComponent(folderName)
                
                do {
                    try FileManager.default.createDirectory(atPath: newFolderPath, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    // TODO: Handle Errors
                    print("Error creating folder in FileNodeView... \(error)")
                }
            })
        })
        .alert("Folder Exists", isPresented: $alertShowingErrorAddingFolderFolderExists, actions: {
            Button("Close") {
                
            }
        }, message: {
            Text("A folder with that name already exists.")
        })
    }

    private func getAllFiles(atPath path: String) -> [String] {
        var allFiles = [String]()
        
        if let enumerator = FileManager.default.enumerator(atPath: path) {
            for case let filePath as String in enumerator {
                allFiles.append((path as NSString).appendingPathComponent(filePath))
            }
        }
        
        return allFiles
    }
}

#Preview {

    TabAddingFileSystemView(
        directory: .constant(""),
        selectedFilepaths: .constant([]),
        searchText: .constant(""),
        tabsViewModel: TabsViewModel()

    )

}