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
    
    @State var directory: String = "~/Downloads/test_dir"
    
    
    @StateObject private var fileSystemGenerator: FileSystemGenerator = FileSystemGenerator()
    
//    @State private var selectedFilepaths: [String] = []
//    @State private var openedFile: String?
    
    @State private var openTabs: [CodeViewModel] = []
//    @State private var openTab: CodeViewModel = CodeViewModel(filepath: nil)
//    @State private var openTab: CodeViewModel = CodeViewModel(filepath: nil)
    @State private var openTab: CodeViewModel?
//    @State private var openedTabIndex: Int?
    
//    @ObservedObject var tempMainViewModel: TempMainViewModel
    
//    var openTab: CodeViewModel = CodeViewModel(filepath: "")
    
//    @State private var currentWideScope: Scope?
    
    
    var body: some View {
        ZStack {
            VStack {
                // Tab View
                if !openTabs.isEmpty {
                    TabsView(
                        openTabs: $openTabs,
                        selectedTab: $openTab,
                        onSelect: { selectedTab in
                            self.openTab = selectedTab
                        })
//                    }
                }
                
                HSplitView {
//                    // File Browser
//                    TabAddingFileSystemView(
//                        directory: $directory,
//                        selectedFilepaths: $selectedFilepaths,
//                        openTab: $openTab,
//                        openTabs: $openTabs)
                    // File Browser
                    FileBrowserView(
                        baseDirectory: $directory,
                        openTab: $openTab,
                        openTabs: $openTabs)
                    
                    if let openTab = openTab {
                        // Code View
                        var openTabBinding: Binding<CodeViewModel> {
                            Binding(
                                get: {
                                    self.openTab!
                                },
                                set: { value in
                                    
                                })
                        }
                        
                        CodeView(codeViewModel: openTabBinding)
                    } else {
                        // No Tabs View
                        ZStack {
                            Colors.background
                            
                            Text("No File Selected")
                            
                            // TODO: File Selection Buttons and stuff
                        }
                    }
                }
            }
            
//            VStack {
//                Spacer()
//                HStack {
//                    // Wide Scope Controls
//                    WideScopeControlsView(
//                        scope: $currentWideScope,
//                        selectedFilepaths: $selectedFilepaths,
//                        onSubmit: { actionType in
//                            
//                        })
//                    .padding()
//                    .padding(.bottom)
//                    .padding(.bottom)
//                    Spacer()
//                }
//            }
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
