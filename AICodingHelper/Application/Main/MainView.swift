//
//  MainView.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 6/26/24.
//

import CodeEditor
import Foundation
import SwiftUI

//class TempMainViewModel: ObservableObject {
//    @Published var openTabs: [CodeViewModel] = []
//    @Published var selecte
//}

struct MainView: View {
    
    @Binding var directory: String // = NSString(string: "/Users/alexcoundouriotis/Xcode Projects/AICodingHelper/AICodingHelper/Application/Files").expandingTildeInPath
    @Binding var popupShowingCreateAIFile: Bool
    @Binding var popupShowingCreateBlankFile: Bool
    @Binding var popupShowingCreateFolder: Bool
    
    
    private static let defaultMultiFileParentFileSystemName = "TempSelection"
    

    @Environment(\.dismiss) private var dismiss
    @Environment(\.undoManager) private var undoManager
    
    @EnvironmentObject private var focusViewModel: FocusViewModel
    @EnvironmentObject private var remainingUpdater: RemainingUpdater
    
    @FocusState private var editorFocused: Bool
    
    
//    @StateObject private var fileSystemGenerator: FileSystemGenerator = FileSystemGenerator()
    @StateObject private var progressTracker: ProgressTracker = ProgressTracker()
    @StateObject private var tabsViewModel: TabsViewModel = TabsViewModel()
    
    @State private var fileBrowserSelectedFilepaths: [String] = []
    
    @State private var currentCodeGenerationPlan: CodeGenerationPlan?
    @State private var currentCodeGenerationPlanTokenEstimation: Int?
    
    private static let additionalTokensForEstimationPerFile: Int = Constants.Additional.additionalTokensForEstimationPerFile
    
    @State private var navigationSplitViewColumnVisibility: NavigationSplitViewVisibility = .doubleColumn
    
    @State private var alertShowingWideScopeChatGenerationEstimatedTokensApproval: Bool = false
    @State private var alertShowingNotEnoughTokensToPerformTask: Bool = false
    
    @State private var alertShowingNewBlankFile: Bool = false
    @State private var alertShowingNewFolder: Bool = false
    
    @State private var codeViewHasSelection: Bool = false
    
    @State private var isLoadingBrowser: Bool = false
    
    @State private var newEntityName: String = ""
    
    
    private var currentScope: Binding<Scope> {
        Binding(
            get: {
                if focusViewModel.focus == .editor {
                    // If code view has selection return highlight, otherwise return file
                    return codeViewHasSelection ? .highlight : .file
                } else {
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
                    // File Browser
                    FileBrowserView(
                        baseDirectory: $directory,
                        selectedFilepaths: $fileBrowserSelectedFilepaths,
                        tabsViewModel: tabsViewModel)
                    .frame(idealWidth: 250.0)
                }) {
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
                                .onChange(of: editorFocused) { newValue in
                                    if newValue {
                                        // Change focus in focusViewModel when focus state is changed
                                        focusViewModel.focus = .editor
                                    }
                                }
                        } else {
                            // No Tabs View
//                            VStack {
//                                CodeEditor(source: "")
//                            }
                            VStack {
                                Text("Double-Click a File to Open")
                                
                                Button("Go Home") {
                                    directory = ""
                                }
                            }
                        }
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
                            
                        }) {
                            HStack {
                                Text(Image(systemName: "sparkles"))
                                
                                Text("\(remainingUpdater.remaining ?? 0)")
                            }
                        }
                    }
                }
                .overlay {
                    if isLoadingBrowser {
                        ZStack {
                            Colors.foreground
                                .opacity(0.4)
                            
                            VStack {
                                Text("**Performing \(currentScope.wrappedValue.name.capitalized) AI Task**")
                                    .padding()
                                
                                var finalizing: Bool {
                                    progressTracker.completedTasks == progressTracker.totalTasks || progressTracker.estimatedTimeRemaining == 0
                                }
                                
                                if let estimatedTimeRemaining = progressTracker.estimatedTimeRemaining {
                                    if finalizing {
                                        Text("Finalizing...")
                                    } else {
                                        Text("Estimated time remaining: \(String(format: "%.1f", estimatedTimeRemaining))s")
                                    }
                                } else {
                                    Text("Calculating time remaining...")
                                    if let progress = progressTracker.progress {
                                        Text("Progress \(progress)")
                                    }
                                }
                                ProgressView(value: finalizing ? nil : progressTracker.progress, total: ProgressTracker.maxProgress)
                                    .frame(width: 480.0)
                                    .tint(Colors.element)
                                    .padding([.leading, .trailing])
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
                        scope: currentScope,
                        focusViewModel: focusViewModel,
                        selectedFilepaths: $fileBrowserSelectedFilepaths,
                        onSubmit: { actionType, userInput, generateOptions in
                            Task {
                                // Ensure authToken
                                let authToken: String
                                do {
                                    authToken = try await AuthHelper.ensure()
                                } catch {
                                    // TODO: Handle Errors
                                    print("Error ensuring authToken in MainView... \(error)")
                                    return
                                }
                                
                                // Create alternateContextFilepaths and add directory if generateOptions useEntireProject is included
                                var alternateContextFilepaths: [String] = []
                                if generateOptions.contains(.useEntireProjectAsContext) {
                                    alternateContextFilepaths.append(directory)
                                }
                                
                                // Do generation by scope
                                switch currentScope.wrappedValue {
                                case .project:
                                    // Generate with wide scope generator using single object array with directory as filepaths
                                    do {
                                        // Defer setting isLoadingBrowser to false
                                        defer {
                                            DispatchQueue.main.async {
                                                self.isLoadingBrowser = false
                                            }
                                        }
                                        
                                        // Set isLoadingBrowser to true
                                        DispatchQueue.main.async {
                                            self.isLoadingBrowser = true
                                        }
                                        
                                        // Create instructions from action aiPrompt and userInput
                                        let instructions = actionType.aiPrompt + (userInput.isEmpty ? "" : "\n" + userInput)
                                        
                                        // Create Plan and set to currentCodeGenerationPlan
                                        guard let plan = try await CodeGenerationPlanner.makePlan(
                                            authToken: authToken,
                                            model: .GPT4o,
                                            editActionSystemMessage: Constants.Additional.editSystemMessage,
                                            instructions: instructions,
                                            selectedFilepaths: [directory],
                                            copyCurrentFilesToTempFiles: generateOptions.contains(.copyCurrentFilesToTempFiles)) else {
                                            // TODO: Handle Errors
                                            print("Could not unwrap plan after making plan in MainView!")
                                            return
                                        }
                                        DispatchQueue.main.async {
                                            self.currentCodeGenerationPlan = plan
                                        }
                                        
                                        // Estimate tokens for plan and set to currentCodeGenerationPlanTokenEstimation
                                        let tokenEstimation = await TokenCalculator.getEstimatedTokens(
                                            authToken: authToken,
                                            codeGenerationPlan: plan)
                                        DispatchQueue.main.async {
                                            self.currentCodeGenerationPlanTokenEstimation = tokenEstimation
                                        }
                                        
                                        // Set alertShowingWideScopeChatGenerationEstimatedTokensApproval alert to true
                                        DispatchQueue.main.async {
                                            self.alertShowingWideScopeChatGenerationEstimatedTokensApproval = true
                                        }
                                    } catch {
                                        // TODO: Handle Errors
                                        print("Error building refactor files task in MainView... \(error)")
                                    }
                                case .multifile:
                                    // Generate with wide scope generator
                                    do {
                                        // Defer setting isLoadingBrowser to false
                                        defer {
                                            DispatchQueue.main.async {
                                                self.isLoadingBrowser = false
                                            }
                                        }
                                        
                                        // Set isLoadingBrowser to true
                                        DispatchQueue.main.async {
                                            self.isLoadingBrowser = true
                                        }
                                        
                                        // Create instructions from action aiPrompt and userInput
                                        let instructions = actionType.aiPrompt + (userInput.isEmpty ? "" : "\n" + userInput)
                                        
                                        // Create Plan and set to currentCodeGenerationPlan
                                        guard let plan = try await CodeGenerationPlanner.makePlan(
                                            authToken: authToken,
                                            model: .GPT4o,
                                            editActionSystemMessage: Constants.Additional.editSystemMessage,
                                            instructions: instructions,
                                            selectedFilepaths: fileBrowserSelectedFilepaths,
                                            copyCurrentFilesToTempFiles: generateOptions.contains(.copyCurrentFilesToTempFiles)) else {
                                            // TODO: Handle Errors
                                            print("Could not unwrap plan after making plan in MainView!")
                                            return
                                        }
                                        DispatchQueue.main.async {
                                            self.currentCodeGenerationPlan = plan
                                        }
                                        
                                        // Estimate tokens for plan and set to currentCodeGenerationPlanTokenEstimation
                                        let tokenEstimation = await TokenCalculator.getEstimatedTokens(
                                            authToken: authToken,
                                            codeGenerationPlan: plan)
                                        DispatchQueue.main.async {
                                            self.currentCodeGenerationPlanTokenEstimation = tokenEstimation
                                        }
                                        
                                        // Set alertShowingWideScopeChatGenerationEstimatedTokensApproval alert to true
                                        DispatchQueue.main.async {
                                            self.alertShowingWideScopeChatGenerationEstimatedTokensApproval = true
                                        }
                                    } catch {
                                        // TODO: Handle Errors
                                        print("Error refactoring files in MainView... \(error)")
                                    }
                                case .file: // This only contains generation logic for the opened view in CodeView and falls through to directory if the intent is not to use the open view but to use a file in the browser as the directory case handles files and directories the same but exclusively from the browser
                                    // If focus is on editor and openTab can be unwrapped use openTab to generate, otherwise fallthrough to directory to generate for the selected filepath from the browser
                                    if focusViewModel.focus == .editor,
                                       let openTab = tabsViewModel.openTab {
                                        // Start progressTracker with one total task
                                        DispatchQueue.main.async {
                                            progressTracker.startEstimation(totalTasks: 1)
                                        }
                                        
                                        // Generate with openTab narrow scope generator
                                        await openTab.generate(
                                            authToken: authToken,
                                            remainingTokens: remainingUpdater.remaining,
                                            action: actionType,
                                            additionalInput: userInput,
                                            scope: .file,
                                            context: [], // TODO: Use project as context and stuff
                                            undoManager: undoManager,
                                            options: generateOptions)
                                        
                                        // Complete task in progressTracker
                                        DispatchQueue.main.async {
                                            progressTracker.completeTask()
                                        }
                                    } else {
                                        // If file is not open fallthrough to directory logic
                                        fallthrough
                                    }
                                case .directory: // Due to the nature of the generation logic, this is able to be used for both single files and directories in the browser. Its generation exclusively updates files in the wide scope rather than narrow directly in the editor
                                    // Create and ensure unwrap firstFileBrowserSelectedFilepath
                                    guard let firstFileBrowserSelectedFilepath = fileBrowserSelectedFilepaths[safe: 0] else {
                                        // TODO: Handle Errors
                                        print("Could not unwrap selected file in MainView!")
                                        return
                                    }
                                    
                                    // Generate with wide scope generator
                                    do {
                                        // Defer setting isLoadingBrowser to false
                                        defer {
                                            DispatchQueue.main.async {
                                                self.isLoadingBrowser = false
                                            }
                                        }
                                        
                                        // Set isLoadingBrowser to true
                                        DispatchQueue.main.async {
                                            self.isLoadingBrowser = true
                                        }
                                        
                                        // Create instructions from action aiPrompt and userInput
                                        let instructions = actionType.aiPrompt + (userInput.isEmpty ? "" : "\n" + userInput)
                                        
                                        // Create Plan and set to currentCodeGenerationPlan
                                        guard let plan = try await CodeGenerationPlanner.makePlan(
                                            authToken: authToken,
                                            model: .GPT4o,
                                            editActionSystemMessage: Constants.Additional.editSystemMessage,
                                            instructions: instructions,
                                            selectedFilepaths: [firstFileBrowserSelectedFilepath],
                                            copyCurrentFilesToTempFiles: generateOptions.contains(.copyCurrentFilesToTempFiles)) else {
                                            // TODO: Handle Errors
                                            print("Could not unwrap plan after making plan in MainView!")
                                            return
                                        }
                                        DispatchQueue.main.async {
                                            self.currentCodeGenerationPlan = plan
                                        }
                                        
                                        // Estimate tokens for plan and set to currentCodeGenerationPlanTokenEstimation
                                        let tokenEstimation = await TokenCalculator.getEstimatedTokens(
                                            authToken: authToken,
                                            codeGenerationPlan: plan)
                                        DispatchQueue.main.async {
                                            self.currentCodeGenerationPlanTokenEstimation = tokenEstimation
                                        }
                                        
                                        // Set alertShowingWideScopeChatGenerationEstimatedTokensApproval alert to true
                                        DispatchQueue.main.async {
                                            self.alertShowingWideScopeChatGenerationEstimatedTokensApproval = true
                                        }
                                    } catch {
                                        // TODO: Handle Errors
                                        print("Error refactoring files in MainView... \(error)")
                                    }
                                case .highlight:
                                    if let openTab = tabsViewModel.openTab {
                                        // Start progressTracker with one total task
                                        DispatchQueue.main.async {
                                            progressTracker.startEstimation(totalTasks: 1)
                                        }
                                        
                                        await openTab.generate(
                                            authToken: authToken,
                                            remainingTokens: remainingUpdater.remaining,
                                            action: actionType,
                                            additionalInput: userInput,
                                            scope: .highlight,
                                            context: [],
                                            undoManager: undoManager,
                                            options: generateOptions)
                                        
                                        // Complete task in progressTracker
                                        DispatchQueue.main.async {
                                            progressTracker.completeTask()
                                        }
                                    } else {
                                        // TODO: Handle Errors
                                        return
                                    }
                                }
                                
                                // Update remaining
                                do {
                                    try await remainingUpdater.update(authToken: authToken)
                                } catch {
                                    // TODO: Handle Errors
                                    print("Error updating remaining in MainView... \(error)")
                                }
                            }
                        })
                    .shadow(color: Colors.foregroundText.opacity(0.05), radius: 8.0)
                    .padding()
                    .padding(.bottom)
                    .padding(.bottom)
                }
            }
        }
//        .popover(isPresented: $alertShowingWideScopeChatGenerationEstimatedTokensApproval) {
//            VStack {
//                Text("")
//            }
//        }
        .alert("Approve AI Task", isPresented: $alertShowingWideScopeChatGenerationEstimatedTokensApproval, actions: {
            Button("Cancel", role: .cancel) {
                
            }
            
            Button("Start") {
                refactorFiles()
            }
        }, message: {
            Text("Task Details:\n")
//            +
//            Text("• \(currentWideScopeChatGenerationTask?.filepathCodeGenerationPrompts.count ?? -1) Files\n")
            +
            Text("• \(currentCodeGenerationPlanTokenEstimation ?? -1) Est. Tokens")
        })
        .alert("More Tokens Needed", isPresented: $alertShowingNotEnoughTokensToPerformTask, actions: {
            Button("Close") {
                
            }
        }, message: {
            Text("Purchase more tokens to perform this AI task.")
        })
        .aiFileCreatorPopup(
            isPresented: $popupShowingCreateAIFile,
            baseFilepath: fileOrFolderCreatorBaseFilepath,
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
        .onAppear {
            // If directory isEmpty onAppear dismiss
            if directory.isEmpty {
                dismiss.callAsFunction()
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
    
    
    func refactorFiles() {
        guard let currentCodeGenerationPlan = currentCodeGenerationPlan,
              let currentCodeGenerationPlanTokenEstimation = currentCodeGenerationPlanTokenEstimation else {
            // TODO: Handle Errors
            print("Could not unwrap currentCodeGenerationPlan in MainView!")
            return
        }
        
        guard currentCodeGenerationPlanTokenEstimation + MainView.additionalTokensForEstimationPerFile < remainingUpdater.remaining else {
            // TODO: Handle Errors
            print("Current code generation plan token estimation plus additional tokens for estimation per file exceeds remaining tokens!")
            return
        }
        
        Task {
            // Defer setting isLoadingBrowser to false
            defer {
                DispatchQueue.main.async {
                    self.isLoadingBrowser = false
                }
            }
            
            // Set isLoadingBrowser to true
            await MainActor.run {
                isLoadingBrowser = true
            }
            
            // Ensure authToken
            let authToken: String
            do {
                authToken = try await AuthHelper.ensure()
            } catch {
                // TODO: Handle Errors
                print("Error ensuring authToken in MainView... \(error)")
                return
            }
            
            // Generate and refactor
            do {
                try await CodeGenerationPlanExecutor.generateAndRefactor(
                    authToken: authToken,
                    plan: currentCodeGenerationPlan)
            } catch {
                // TODO: Handle Errors
                print("Error generating and refactoring çode in MainView... \(error)")
            }
        }
        
        
//        guard let currentWideScopeChatGenerationTask = currentWideScopeChatGenerationTask,
//              let currentWideScopeChatGenerationTaskTokenEstimation = currentWideScopeChatGenerationTaskTokenEstimation else {
//            // TODO: Handle Errors
//            print("Could not unwrap currentWideScopeChatGenerationTask or currentWideScopeChatGenerationTaskTokenEstimation in MainView!")
//            return
//        }
//        
//        guard currentWideScopeChatGenerationTaskTokenEstimation + MainView.additionalTokensForEstimationPerFile < remainingUpdater.remaining else {
//            // Show not enough tokens alert
//            DispatchQueue.main.async {
//                self.alertShowingNotEnoughTokensToPerformTask = true
//            }
//            return
//        }
//        
//        Task {
//            // Defer setting isLoadingBrowser to false
//            defer {
//                DispatchQueue.main.async {
//                    self.isLoadingBrowser = false
//                }
//            }
//            
//            // Set isLoadingBrowser to true
//            await MainActor.run {
//                isLoadingBrowser = true
//            }
//            
//            // Ensure authToken
//            let authToken: String
//            do {
//                authToken = try await AuthHelper.ensure()
//            } catch {
//                // TODO: Handle Errors
//                print("Error ensuring authToken in MainView... \(error)")
//                return
//            }
//            
//            // Refactor files
//            do {
//                try await EditFileCodeGenerator.refactorFiles(
//                    authToken: authToken,
//                    wideScopeChatGenerationTask: currentWideScopeChatGenerationTask,
//                    progressTracker: progressTracker)
//            } catch {
//                // TODO: Handle Errors
//                print("Error refactoring files in MainView... \(error)")
//            }
//            
//            // Update remaining
//            do {
//                try await remainingUpdater.update(authToken: authToken)
//            } catch {
//                // TODO: Handle Errors
//                print("Error updating remaining in MainView... \(error)")
//            }
//        }
    }
    
}

#Preview {
    
    MainView(
        directory: .constant(NSString(string: "~/Downloads/test_dir").expandingTildeInPath),
        popupShowingCreateAIFile: .constant(false),
        popupShowingCreateBlankFile: .constant(false),
        popupShowingCreateFolder: .constant(false))
        .frame(width: 650, height: 600)
        .environmentObject(FocusViewModel())
        .environmentObject(RemainingUpdater())
    
}
