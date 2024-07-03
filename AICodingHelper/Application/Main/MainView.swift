//
//  MainView.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 6/26/24.
//

import CodeEditor
import SwiftUI

//class TempMainViewModel: ObservableObject {
//    @Published var openTabs: [CodeViewModel] = []
//    @Published var selecte
//}

struct MainView: View {
    
    @State var directory: String = "~/Downloads/files_temp"
    
    
    private static let defaultMultiFileParentFileSystemName = "TempSelection"
    
    
    @Environment(\.undoManager) private var undoManager
    
    
    @StateObject private var fileSystemGenerator: FileSystemGenerator = FileSystemGenerator()
    @StateObject private var wideScopeChatGenerator: WideScopeChatGenerator = WideScopeChatGenerator()
    @StateObject private var tabsViewModel: TabsViewModel = TabsViewModel()
    
    @State private var fileBrowserSelectedFilepaths: [String] = []
    
    
    private var currentWideScopeName: Binding<String> {
        Binding(
            get: {
                if fileBrowserSelectedFilepaths.count == 1 {
                    if let file = fileBrowserSelectedFilepaths[safe: 0],
                       FileSystem.from(path: NSString(string: file).expandingTildeInPath)?.fileType == .folder {
                        // If fileBrowserSelectedFilepaths contains one object and when transforemd to a FileSystem is type of folder return "Directory"
                        return "Directory"
                    } else {
                        // Otherwise and if fileBrowserSelectedFilepaths contains one object return "File"
                        return "File"
                    }
                } else if fileBrowserSelectedFilepaths.count > 1 {
                    // If there are multiple files in fileBrowserSelectedFilepaths return "Files"
                    return "Files"
                } else if fileBrowserSelectedFilepaths.count == 0 {
                    // If there are no files in fileBrowserSelectedFilepaths return "Project"
                    return "Project"
                }
                
                // Return blank string
                return ""
            },
            set: { value in
                
            })
    }
    
    
    var body: some View {
        ZStack {
            VStack {
                NavigationSplitView(sidebar: {
                    // File Browser
                    FileBrowserView(
                        baseDirectory: $directory,
                        selectedFilepaths: $fileBrowserSelectedFilepaths,
                        tabsViewModel: tabsViewModel)
                }) {
                    // Tab View
                    VStack(spacing: 0.0) {
                        TabsView(tabsViewModel: tabsViewModel)
                        
                        if let openTab = tabsViewModel.openTab {
                            // Code View
                            var openTabBinding: Binding<CodeViewModel> {
                                Binding(
                                    get: {
                                        openTab
                                    },
                                    set: { value in
                                        
                                    })
                            }
                            
                            CodeView(codeViewModel: openTabBinding)
                        } else {
                            // No Tabs View
                            VStack {
                                //                            }
                                //                            CodeView(codeViewModel: .constant(CodeViewModel(filepath: nil)))
                                //                            CodeEditorContainer(fileText: .constant(""), fileSelection: .constant("".startIndex..<"".startIndex), fileLanguage: .constant(.swift))
                                CodeEditor(source: "")
                                
                                //                            Text("No File Selected")
                                
                                // TODO: File Selection Buttons and stuff
                            }
                        }
                    }
                }
            }
        }
        .overlay {
            // Wide Scope Controls
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    WideScopeControlsView(
                        scopeName: currentWideScopeName,
                        selectedFilepaths: $fileBrowserSelectedFilepaths,
                        onSubmit: { actionType, generateOptions in
                            // If selectedFilepaths contains at least one item refactor files with it or them, otherwise refactor project TODO: Maybe make this implementation better in regards to doing entire project refactor
                            if fileBrowserSelectedFilepaths.count > 0 {
                                // Get rootFile using FileSystem from with the first selected path if there is only one item and FileSystem from with all selected paths if there are multiple. The reason to use the different function is because from without paths and parent name will make it the root node and fetch all the items whereas with paths it will create a parent with parent name to hold the paths and then assemble the FileSystem normally
                                guard let rootFile = fileBrowserSelectedFilepaths.count == 1 ? FileSystem.from(path: fileBrowserSelectedFilepaths[0]) : FileSystem.from(
                                    parentName: MainView.defaultMultiFileParentFileSystemName,
                                    paths: fileBrowserSelectedFilepaths) else {
                                    // TODO: Handle Errors
                                    print("Error unwrapping rootFile in FileBrowserView!")
                                    return
                                }
                                
                                wideScopeChatGenerator.refactorFiles(
                                    action: actionType,
                                    userInput: nil, // TODO: Add this
                                    rootDirectoryPath: NSString(string: directory).expandingTildeInPath,
                                    rootFile: rootFile,
                                    alternativeContextFiles: nil,
                                    options: generateOptions)
                            } else {
                                // Refactor project
                                wideScopeChatGenerator.refactorProject(
                                    action: actionType,
                                    userInput: nil, // TODO: Add this
                                    rootDirectoryPath: NSString(string: directory).expandingTildeInPath,
                                    options: generateOptions)
                            }
                        })
                    .shadow(color: Colors.foregroundText.opacity(0.05), radius: 8.0)
                    .padding()
                    .padding(.bottom)
                    .padding(.bottom)
                }
            }
        }
//        .onAppear {
//            Task {
//                if let fileSystem = FileSystem.from(path: NSString(string: directory).expandingTildeInPath) {
//                    let fileSystemJSON = try await fileSystemGenerator.getFileSystem(authToken: AuthHelper.get()!, model: .GPT4o, input: "", fileSystem: fileSystem)
//                    print(fileSystemJSON)
//                }
//            }
//        }
    }
    
}

#Preview {
    
    MainView()
        .frame(width: 650, height: 600)
    
}
