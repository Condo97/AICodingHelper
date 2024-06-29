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
    
    
    @State private var selectedPath: String?
//    @State private var openedFile: String?
    
    @State private var openTabs: [CodeViewModel] = []
//    @State private var openTab: CodeViewModel = CodeViewModel(filepath: nil)
//    @State private var openTab: CodeViewModel = CodeViewModel(filepath: nil)
    @State private var openTab: CodeViewModel?
//    @State private var openedTabIndex: Int?
    
//    @ObservedObject var tempMainViewModel: TempMainViewModel
    
//    var openTab: CodeViewModel = CodeViewModel(filepath: "")
    
    
    var body: some View {
        ZStack {
            VStack {
                // Tab View
                if !openTabs.isEmpty {
//                    TabView(selection: $openTab) {
                    HStack {
                        ForEach(openTabs) { openTab in
                            CodeTabView(
                                codeViewModel: openTab,
                                onSelect: {
                                    self.openTab = openTab
                                },
                                onClose: {
                                    
                                })
                        }
                    }
//                    }
//                    TabsView(
//                        openTabs: $openTabs,
//                        selectedTab: openTabs[openTabIndex ?? 0],
//                        onSelect: { codeViewModel in
//                            if let selectedTab = openTabs.firstIndex(where: {$0 === codeViewModel}) {
//                                self.openTabIndex = selectedTab
//                            }
//                        })
                }
                
                HSplitView {
                    // File Browser
                    TabAddingFileSystemView(
                        directory: $directory,
                        selectedPath: $selectedPath,
                        openTabs: $openTabs)
                    
                    // Code View
                    if let openTab = openTab {
                        var openTabBinding: Binding<CodeViewModel> {
                            Binding(
                                get: {
                                    self.openTab!
                                },
                                set: { value in
                                    
                                })
                        }
                        CodeView(codeViewModel: openTabBinding)
                    }
                }
            }
            
            // Wide Scope Controls
            
        }
    }
    
}

//#Preview {
//    
//    MainView()
//        .frame(width: 600, height: 500)
//    
//}
