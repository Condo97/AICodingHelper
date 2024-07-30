//
//  MainView.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 6/26/24.
//

import CodeEditor
import Foundation
import SwiftUI


struct MainView: View {
    
    @Binding var directory: String // = NSString(string: "/Users/alexcoundouriotis/Xcode Projects/AICodingHelper/AICodingHelper/Application/Files").expandingTildeInPath
    @Binding var popupShowingCreateAIFile: Bool
    @Binding var popupShowingCreateBlankFile: Bool
    @Binding var popupShowingCreateFolder: Bool
    @Binding var popupShowingOpenProject: Bool
    
    
    private static let defaultMultiFileParentFileSystemName = "TempSelection"
    

    @Environment(\.undoManager) private var undoManager
    
    @EnvironmentObject private var activeSubscriptionUpdater: ActiveSubscriptionUpdater
    @EnvironmentObject private var focusViewModel: FocusViewModel
    @EnvironmentObject private var remainingUpdater: RemainingUpdater
    
    @FocusState private var editorFocused: Bool
    
    
    @StateObject private var progressTracker: ProgressTracker = ProgressTracker()
    @StateObject private var tabsViewModel: TabsViewModel = TabsViewModel()
    
    @State private var fileBrowserSelectedFilepaths: [String] = []
    
    private static let additionalTokensForEstimationPerFile: Int = Constants.Additional.additionalTokensForEstimationPerFile
    
    @State private var navigationSplitViewColumnVisibility: NavigationSplitViewVisibility = .all
    
    @State private var alertShowingWideScopeChatGenerationEstimatedTokensApproval: Bool = false
    @State private var alertShowingNotEnoughTokensToPerformTask: Bool = false
    
    @State private var alertShowingNewBlankFile: Bool = false
    @State private var alertShowingNewFolder: Bool = false
    
    @State private var isShowingUltraView: Bool = false
    
    @State private var codeViewHasSelection: Bool = false
    
    @State private var currentDiscussion: Discussion?
    
    @State private var isLoadingCodeGeneration: Bool = false
    
    @State private var newEntityName: String = ""
    
    
    private var currentScope: Binding<Scope> {
        Binding(
            get: {
                if fileBrowserSelectedFilepaths.count == 1 {
                    if let firstFileBrowserSelectedFilepath = fileBrowserSelectedFilepaths[safe: 0] {
                        // If the first selected filepath is the project root file return project
                        if firstFileBrowserSelectedFilepath == directory {
                            return .project
                        }
                        
                        // Directory if only one file selected and it is a directory
                        var isDirectory: ObjCBool = false
                        if FileManager.default.fileExists(atPath: firstFileBrowserSelectedFilepath, isDirectory: &isDirectory) {
                            if isDirectory.boolValue {
                                return .directory
                            }
                        }
                    }
                    
                    // File otherwise if only one selected
                    return .file
                } else if fileBrowserSelectedFilepaths.count > 1 {
                    // If the project is selected return project
                    if fileBrowserSelectedFilepaths.contains(where: {$0 == directory}) {
                        return .project
                    }
                    
                    // Multifile if multiple selected
                    return .multifile
                } else {
                    // Project if none selected
                    return .project
                }
            },
            set: { value in
                // No actions
            })
    }
    
    private var fileOrFolderCreatorBaseFilepath: String {
        if let fileBrowserSelectedFilepath = fileBrowserSelectedFilepaths[safe: 0] {
            var isDirectory: ObjCBool = false
            if FileManager.default.fileExists(atPath: fileBrowserSelectedFilepath, isDirectory: &isDirectory) {
                if isDirectory.boolValue {
                    // Return as is
                    return fileBrowserSelectedFilepath
                } else {
                    // Return directory path from file
                    return URL(fileURLWithPath: fileBrowserSelectedFilepath).deletingLastPathComponent().path
                }
            }
        }
        
        // Return project directory otherwise
        return directory
    }
    
    
    var body: some View {
        ZStack {
            VStack {
                NavigationSplitView(columnVisibility: $navigationSplitViewColumnVisibility, sidebar: {
                    ZStack {
                        if !directory.isEmpty {
                            // File Browser
                            FileBrowserView(
                                baseDirectory: $directory,
                                selectedFilepaths: $fileBrowserSelectedFilepaths,
                                tabsViewModel: tabsViewModel)
                        }
                    }
                    .navigationSplitViewColumnWidth(ideal: 250.0)
                }) {
                    HSplitView {
                        // Tab View
                        VStack(spacing: 0.0) {
                            if !tabsViewModel.openTabs.isEmpty {
                                TabsView(tabsViewModel: tabsViewModel)
                            }
                            
                            if let openTab = tabsViewModel.openTab {
                                // Code View
                                var openTabBinding: Binding<CodeViewModel> {
                                    Binding(
                                        get: {
                                            tabsViewModel.openTab ?? CodeViewModel(filepath: nil) // It is critical it is this and not openTab!
                                        },
                                        set: { value in
                                            
                                        })
                                }
                                
                                CodeView(
                                    codeViewModel: openTabBinding,
                                    hasSelection: $codeViewHasSelection)
                                .focused($editorFocused)
                            } else {
                                // No Tabs View
                                //                            VStack {
                                //                                CodeEditor(source: "")
                                //                            }
                                HStack {
                                    Spacer()
                                    VStack {
                                        Spacer()
                                        if directory.isEmpty {
                                            Text("No Project Selected")
                                            Button("Open Project \(Image(systemName: "folder"))") {
                                                popupShowingOpenProject = true
                                            }
                                        } else {
                                            Text("Double-Click a File to Open")
                                            Button("Go Home \(Image(systemName: "house"))") {
                                                popupShowingOpenProject = true
                                            }
                                        }
                                        Spacer()
                                    }
                                    Spacer()
                                }
                            }
                        }
                        .frame(maxHeight: .infinity)
                        
                        CodeGeneratorContainer(
                            rootFilepath: $directory,
                            tabsViewModel: tabsViewModel,
                            fileBrowserSelectedFilepaths: $fileBrowserSelectedFilepaths,
                            isLoading: $isLoadingCodeGeneration)
                        .background(Color.foreground)
                        //                    .navigationSplitViewColumnWidth(currentScope.wrappedValue == .directory ? .infinity : 550.0)
                    }
                }
                .toolbar {
                    ToolbarItem {
                        Menu("", systemImage: "plus") {
                            Button("New AI File...") {
                                popupShowingCreateAIFile = true
                            }
                            
                            Divider()
                            
                            Button("New Blank File...") {
                                popupShowingCreateBlankFile = true
                            }
                            
                            Button("New Folder...") {
                                popupShowingCreateFolder = true
                            }
                        }
                    }
                    
                    ToolbarItem {
                        Button(action: {
                            isShowingUltraView = true
                        }) {
                            HStack {
                                Text(Image(systemName: "sparkles"))
                                
                                if activeSubscriptionUpdater.openAIKey != nil {
                                    if activeSubscriptionUpdater.openAIKeyIsValid {
                                        Text("Using OpenAI Key")
                                    } else {
                                        Text("\(remainingUpdater.remaining ?? 0)")
                                        
                                        Image(systemName: "exclamationmark.circle")
                                            .imageScale(.medium)
                                            .foregroundStyle(.red)
                                    }
                                } else {
                                    Text("\(remainingUpdater.remaining ?? 0)")
                                }
                            }
                        }
                    }
                }
//                .overlay {
//                    if isLoadingBrowser {
//                        ZStack {
//                            Colors.foreground
//                                .opacity(0.6)
//                            
//                            VStack {
//                                Text("**Performing \(currentScope.wrappedValue.name.capitalized) AI Task**")
//                                    .padding()
//                                
//                                var finalizing: Bool {
//                                    progressTracker.completedTasks == progressTracker.totalTasks || progressTracker.estimatedTimeRemaining == 0
//                                }
//                                
//                                if let estimatedTimeRemaining = progressTracker.estimatedTimeRemaining {
//                                    if finalizing {
//                                        Text("Finalizing...")
//                                    } else {
//                                        Text("Estimated time remaining: \(String(format: "%.1f", estimatedTimeRemaining))s")
//                                    }
//                                } else {
//                                    Text("Calculating time remaining...")
//                                    if let progress = progressTracker.progress {
//                                        Text("Progress \(progress)")
//                                    }
//                                }
//                                ProgressView(value: finalizing ? nil : progressTracker.progress, total: ProgressTracker.maxProgress)
//                                    .frame(width: 480.0)
//                                    .tint(Colors.element)
//                                    .padding([.leading, .trailing])
//                            }
//                        }
//                    }
//                }
            }
        }
//        .overlay {
//            // Wide Scope Controls
//            VStack {
//                Spacer()
//                HStack {
//                    Spacer()
//                    CodeGeneratorOverlayView {
//                        CodeGeneratorControlsContainer(
//                            scope: currentScope,
//                            rootFilepath: $directory,
//                            progressTracker: progressTracker,
//                            focusViewModel: focusViewModel,
//                            tabsViewModel: tabsViewModel,
//                            fileBrowserSelectedFilepaths: $fileBrowserSelectedFilepaths,
//                            isLoading: $isLoadingCodeGeneration)
//                        .background(Colors.foreground)
//                        .clipShape(RoundedRectangle(cornerRadius: 14.0))
//                    }
//                    .shadow(color: Colors.foregroundText.opacity(0.05), radius: 8.0)
//                    .padding()
//                    .padding(.bottom)
//                    .padding(.bottom)
//                    .disabled(isLoadingCodeGeneration)
//                }
//            }
//        }
//        .popover(isPresented: $alertShowingWideScopeChatGenerationEstimatedTokensApproval) {
//            VStack {
//                Text("")
//            }
//        }
//        .sheet(isPresented: $alertShowingWideScopeChatGenerationEstimatedTokensApproval) {
//            var currentCodeGenerationPlanUnwrappedBinding: Binding<CodeGenerationPlan> {
//                Binding(
//                    get: {
//                        currentCodeGenerationPlan ?? CodeGenerationPlan(
//                            model: .GPT4o,
//                            rootFilepath: "///--!!!!",
//                            editActionSystemMessage: "",
//                            instructions: "",
//                            copyCurrentFilesToTempFiles: true,
//                            planFC: PlanCodeGenerationFC(steps: []))
//                    },
//                    set: { value in
//                        currentCodeGenerationPlan = value
//                    })
//            }
//            ApprovePlanView(
//                plan: currentCodeGenerationPlanUnwrappedBinding,
//                tokenEstimation: $currentCodeGenerationPlanTokenEstimation,
//                onCancel: {
//                    // Set current code generation plan and its token estimation to nil
//                    currentCodeGenerationPlan = nil
//                    currentCodeGenerationPlanTokenEstimation = nil
//                    
//                    // Dismiss
//                    alertShowingWideScopeChatGenerationEstimatedTokensApproval = false
//                },
//                onStart: {
//                    // Refactor files
//                    refactorFiles()
//                    
//                    // Dismiss
//                    alertShowingWideScopeChatGenerationEstimatedTokensApproval = false
//                })
//        }
        .sheet(isPresented: $isShowingUltraView) {
            UltraView(isPresented: $isShowingUltraView)
        }
//        .alert("Approve AI Task", isPresented: $alertShowingWideScopeChatGenerationEstimatedTokensApproval, actions: {
//            Button("Cancel", role: .cancel) {
//                
//            }
//            
//            Button("Start") {
//                refactorFiles()
//            }
//        }, message: {
//            Text("Task Details:\n")
////            +
////            Text("• \(currentWideScopeChatGenerationTask?.filepathCodeGenerationPrompts.count ?? -1) Files\n")
//            +
//            Text("• \(currentCodeGenerationPlanTokenEstimation ?? -1) Est. Tokens")
//        })
        .alert("More Tokens Needed", isPresented: $alertShowingNotEnoughTokensToPerformTask, actions: {
            Button("Close") {
                
            }
        }, message: {
            Text("Purchase more tokens to perform this AI task.")
        })
        .aiFileCreatorPopup(
            isPresented: $popupShowingCreateAIFile,
            rootFilepath: fileOrFolderCreatorBaseFilepath,
            referenceFilepaths: fileBrowserSelectedFilepaths)
        .blankFileCreatorPopup(
            isPresented: $popupShowingCreateBlankFile,
            path: fileOrFolderCreatorBaseFilepath)
        .folderCreatorPopup(
            isPresented: $popupShowingCreateFolder,
            path: fileOrFolderCreatorBaseFilepath)
        .onReceive(tabsViewModel.$openTab) { newValue in
            // Check open tab file validity
            if let filepath = newValue?.filepath,
               FileManager.default.fileExists(atPath: filepath) {
                // Yay good, do nothing
            } else {
                // Remove from openTabs and set openTab to 
                DispatchQueue.main.async {
                    tabsViewModel.openTabs.removeAll(where: {$0 === newValue})
                }
            }
        }
        .onChange(of: directory) { newValue in
            // Remove all tabs
            DispatchQueue.main.async {
                tabsViewModel.openTab = nil
                tabsViewModel.openTabs = []
            }
        }
        .onChange(of: editorFocused) { newValue in
            if newValue {
                // Change focus in focusViewModel when focus state is changed
                focusViewModel.focus = .editor
            }
        }
        .onReceive(focusViewModel.$focus) { newValue in
            // Set editorFocused to reflect focusViewModel when changed if it does not
            if newValue == .editor && !editorFocused {
                editorFocused = true
            } else if newValue != .editor && editorFocused {
                editorFocused = false
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
    
    MainView(
        directory: .constant(NSString(string: "~/Downloads/test_dir").expandingTildeInPath),
        popupShowingCreateAIFile: .constant(false),
        popupShowingCreateBlankFile: .constant(false),
        popupShowingCreateFolder: .constant(false),
        popupShowingOpenProject: .constant(false))
        .frame(width: 650, height: 600)
        .environmentObject(ActiveSubscriptionUpdater())
        .environmentObject(FocusViewModel())
        .environmentObject(RemainingUpdater())
    
}
