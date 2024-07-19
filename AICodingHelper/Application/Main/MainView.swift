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
    @Binding var popupShowingOpenProject: Bool
    
    
    private static let defaultMultiFileParentFileSystemName = "TempSelection"
    

    @Environment(\.undoManager) private var undoManager
    
    @EnvironmentObject private var activeSubscriptionUpdater: ActiveSubscriptionUpdater
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
    @State private var alertShowingInvalidOpenAIKey: Bool = false
    
    @State private var isShowingUltraView: Bool = false
    
    @State private var codeViewHasSelection: Bool = false
    
    @State private var isLoadingBrowser: Bool = false
    @State private var isLoadingGenerationPlan: Bool = false
    
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
                            VStack {
                                if directory.isEmpty {
                                    Text("No Project Selected")
                                } else {
                                    Text("Double-Click a File to Open")
                                }
                                
                                Button("Open Project \(Image(systemName: "folder"))") {
                                    popupShowingOpenProject = true
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
                .overlay {
                    if isLoadingGenerationPlan {
                        ZStack {
                            Colors.foreground
                                .opacity(0.6)
                            
                            VStack {
                                Text("Planning Generation...")
                                
                                ProgressView()
                            }
                        }
                    }
                }
                .overlay {
                    if isLoadingBrowser {
                        ZStack {
                            Colors.foreground
                                .opacity(0.6)
                            
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
                        onSubmit: { actionType, userInput, referenceFilepaths, generateOptions in
                            // Reset values
                            self.currentCodeGenerationPlan = nil
                            self.currentCodeGenerationPlanTokenEstimation = nil
                            
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
                                
                                // Get openAIKey
                                let openAIKey: String? = activeSubscriptionUpdater.openAIKeyIsValid ? activeSubscriptionUpdater.openAIKey : nil
                                
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
                                        // Defer setting isLoadingGenerationPlan to false
                                        defer {
                                            DispatchQueue.main.async {
                                                self.isLoadingGenerationPlan = false
                                            }
                                        }
                                        
                                        // Set isLoadingGenerationPlan to true
                                        DispatchQueue.main.async {
                                            self.isLoadingGenerationPlan = true
                                        }
                                        
                                        // Create instructions from action aiPrompt and userInput
                                        let instructions = actionType.aiPrompt + (userInput.isEmpty ? "" : "\n" + userInput)
                                        
                                        // Create Plan and set to currentCodeGenerationPlan
                                        guard let plan = try await CodeGenerationPlanner.makePlan(
                                            authToken: authToken,
                                            openAIKey: openAIKey,
                                            model: .GPT4o,
                                            editActionSystemMessage: Constants.Additional.editSystemMessage,
                                            instructions: instructions,
                                            rootFilepath: directory,
                                            selectedFilepaths: FileManager.default.contentsOfDirectory(atPath: directory),//instead of [directory] use all the files and folders in directory [directory],
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
                                    } catch GenerationError.invalidOpenAIKey {
                                        // If received invalidOpenAIKey set openAIKeyIsValid to false and show alert
                                        activeSubscriptionUpdater.openAIKeyIsValid = false
                                        alertShowingInvalidOpenAIKey = true
                                    } catch {
                                        // TODO: Handle Errors
                                        print("Error building refactor files task in MainView... \(error)")
                                    }
                                case .multifile:
                                    // Generate with wide scope generator
                                    do {
                                        // Defer setting isLoadingGenerationPlan to false
                                        defer {
                                            DispatchQueue.main.async {
                                                self.isLoadingGenerationPlan = false
                                            }
                                        }
                                        
                                        // Set isLoadingGenerationPlan to true
                                        DispatchQueue.main.async {
                                            self.isLoadingGenerationPlan = true
                                        }
                                        
                                        // Create instructions from action aiPrompt and userInput
                                        let instructions = actionType.aiPrompt + (userInput.isEmpty ? "" : "\n" + userInput)
                                        
                                        // Create Plan and set to currentCodeGenerationPlan
                                        guard let plan = try await CodeGenerationPlanner.makePlan(
                                            authToken: authToken,
                                            openAIKey: openAIKey,
                                            model: .GPT4o,
                                            editActionSystemMessage: Constants.Additional.editSystemMessage,
                                            instructions: instructions,
                                            rootFilepath: directory,
                                            selectedFilepaths: referenceFilepaths,//fileBrowserSelectedFilepaths,
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
                                    } catch GenerationError.invalidOpenAIKey {
                                        // If received invalidOpenAIKey set openAIKeyIsValid to false and show alert
                                        activeSubscriptionUpdater.openAIKeyIsValid = false
                                        alertShowingInvalidOpenAIKey = true
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
                                            openAIKey: openAIKey,
                                            remainingTokens: remainingUpdater.remaining,
                                            action: actionType,
                                            additionalInput: userInput,
                                            scope: .file,
                                            context: referenceFilepaths.map({FilePrettyPrinter.getFileContent(relativeFilepath: $0, rootFilepath: directory)}) + [], // TODO: Use project as context and stuff
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
                                        // Defer setting isLoadingGenerationPlan to false
                                        defer {
                                            DispatchQueue.main.async {
                                                self.isLoadingGenerationPlan = false
                                            }
                                        }
                                        
                                        // Set isLoadingGenerationPlan to true
                                        DispatchQueue.main.async {
                                            self.isLoadingGenerationPlan = true
                                        }
                                        
                                        // Create instructions from action aiPrompt and userInput
                                        let instructions = actionType.aiPrompt + (userInput.isEmpty ? "" : "\n" + userInput)
                                        
                                        // Create Plan and set to currentCodeGenerationPlan
                                        guard let plan = try await CodeGenerationPlanner.makePlan(
                                            authToken: authToken,
                                            openAIKey: openAIKey,
                                            model: .GPT4o,
                                            editActionSystemMessage: Constants.Additional.editSystemMessage,
                                            instructions: instructions,
                                            rootFilepath: directory,
                                            selectedFilepaths: referenceFilepaths,//[firstFileBrowserSelectedFilepath],
                                            copyCurrentFilesToTempFiles: generateOptions.contains(.copyCurrentFilesToTempFiles)) else {
                                            // TODO: Handle Errors
                                            print("Could not unwrap plan after making plan in MainView!")
                                            return
                                        }
                                        DispatchQueue.main.async {
                                            self.currentCodeGenerationPlan = plan
                                        }
                                        
                                        // If openAIKey is nil or empty estimate tokens for plan and set to currentCodeGenerationPlanTokenEstimation, otherwise set token estimation to nil
                                        if openAIKey == nil || openAIKey!.isEmpty {
                                            let tokenEstimation = await TokenCalculator.getEstimatedTokens(
                                                authToken: authToken,
                                                codeGenerationPlan: plan)
                                            DispatchQueue.main.async {
                                                self.currentCodeGenerationPlanTokenEstimation = tokenEstimation
                                            }
                                        }
                                        
                                        // Set alertShowingWideScopeChatGenerationEstimatedTokensApproval alert to true
                                        DispatchQueue.main.async {
                                            self.alertShowingWideScopeChatGenerationEstimatedTokensApproval = true
                                        }
                                    } catch GenerationError.invalidOpenAIKey {
                                        // If received invalidOpenAIKey set openAIKeyIsValid to false and show alert
                                        activeSubscriptionUpdater.openAIKeyIsValid = false
                                        alertShowingInvalidOpenAIKey = true
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
                                            openAIKey: openAIKey,
                                            remainingTokens: remainingUpdater.remaining,
                                            action: actionType,
                                            additionalInput: userInput,
                                            scope: .highlight,
                                            context: referenceFilepaths.map({FilePrettyPrinter.getFileContent(relativeFilepath: $0, rootFilepath: directory)}) + [],
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
                    .disabled(isLoadingBrowser || isLoadingGenerationPlan)
                }
            }
        }
//        .popover(isPresented: $alertShowingWideScopeChatGenerationEstimatedTokensApproval) {
//            VStack {
//                Text("")
//            }
//        }
        .sheet(isPresented: $alertShowingWideScopeChatGenerationEstimatedTokensApproval) {
            var currentCodeGenerationPlanUnwrappedBinding: Binding<CodeGenerationPlan> {
                Binding(
                    get: {
                        currentCodeGenerationPlan ?? CodeGenerationPlan(
                            model: .GPT4o,
                            rootFilepath: "///--!!!!",
                            editActionSystemMessage: "",
                            instructions: "",
                            copyCurrentFilesToTempFiles: true,
                            planFC: PlanCodeGenerationFC(steps: []))
                    },
                    set: { value in
                        currentCodeGenerationPlan = value
                    })
            }
            ApprovePlanView(
                plan: currentCodeGenerationPlanUnwrappedBinding,
                tokenEstimation: $currentCodeGenerationPlanTokenEstimation,
                onCancel: {
                    // Set current code generation plan and its token estimation to nil
                    currentCodeGenerationPlan = nil
                    currentCodeGenerationPlanTokenEstimation = nil
                    
                    // Dismiss
                    alertShowingWideScopeChatGenerationEstimatedTokensApproval = false
                },
                onStart: {
                    // Refactor files
                    refactorFiles()
                    
                    // Dismiss
                    alertShowingWideScopeChatGenerationEstimatedTokensApproval = false
                })
        }
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
        .alert("Invalid OpenAI Key", isPresented: $alertShowingInvalidOpenAIKey, actions: {
            Button("Close") {
                
            }
        }, message: {
            Text("Your Open AI API Key is invalid and your plan will be used until it is updated. If you believe this is an error please report it!")
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
            
            // Get openAIKey
            let openAIKey = activeSubscriptionUpdater.openAIKeyIsValid ? activeSubscriptionUpdater.openAIKey : nil
            
            // Generate and refactor
            do {
                try await CodeGenerationPlanExecutor().generateAndRefactor(
                    authToken: authToken,
                    openAIKey: openAIKey,
                    plan: currentCodeGenerationPlan,
                    progressTracker: progressTracker)
            } catch GenerationError.invalidOpenAIKey {
                // If received invalidOpenAIKey set openAIKeyIsValid to false and show alert
                activeSubscriptionUpdater.openAIKeyIsValid = false
                alertShowingInvalidOpenAIKey = true
            } catch {
                // TODO: Handle Errors
                print("Error generating and refactoring çode in MainView... \(error)")
            }
        }
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
