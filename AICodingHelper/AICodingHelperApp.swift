//
//  AICodingHelperApp.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 6/26/24.
//

import SwiftUI

@main
struct AICodingHelperApp: App {
    
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openWindow) private var openWindow
    @Environment(\.undoManager) private var undoManager
    
    @StateObject private var activeSubscriptionUpdater: ActiveSubscriptionUpdater = ActiveSubscriptionUpdater()
    @StateObject private var codeEditorSettingsViewModel: CodeEditorSettingsViewModel = CodeEditorSettingsViewModel()
    @StateObject private var focusViewModel: FocusViewModel = FocusViewModel()
    @StateObject private var productUpdater: ProductUpdater = ProductUpdater()
    @StateObject private var remainingUpdater: RemainingUpdater = RemainingUpdater()
    @StateObject private var undoUpdater: UndoUpdater = UndoUpdater()
    
    @State private var directory: String = ""
    
    @State private var popupShowingCreateAIFile = false
    @State private var popupShowingCreateBlankFile = false
    @State private var popupShowingCreateFolder = false
    @State private var isShowingCreateAIProject = false
    @State private var isShowingCreateBlankProject = false
    @State private var isShowingOpenProjectImporter = false
    
    @State private var isShowingHomeView: Bool = false
    

    var body: some Scene {
        WindowGroup {
            MainView(
                directory: $directory,
                popupShowingCreateAIFile: $popupShowingCreateAIFile,
                popupShowingCreateBlankFile: $popupShowingCreateBlankFile,
                popupShowingCreateFolder: $popupShowingCreateFolder,
                popupShowingOpenProject: $isShowingHomeView)
            .grantedPermissionsDirectoryCreator(isPresented: $isShowingCreateBlankProject, projectFolderPath: $directory)
            .grantedPermissionsDirectoryImporter(isPresented: $isShowingOpenProjectImporter, filepath: $directory)
            .aiProjectCreatorPopup(isPresented: $isShowingCreateAIProject, baseFilepath: $directory)
            .environmentObject(activeSubscriptionUpdater)
            .environmentObject(codeEditorSettingsViewModel)
            .environmentObject(focusViewModel)
            .environmentObject(productUpdater)
            .environmentObject(remainingUpdater)
            .environmentObject(undoUpdater)
            .sheet(isPresented: $isShowingHomeView) {
                HomeView(
                    filepath: $directory,
                    isShowingCreateAIProject: $isShowingCreateAIProject,
                    isShowingCreateBlankProject: $isShowingCreateBlankProject,
                    isShowingOpenFileImporter: $isShowingOpenProjectImporter)
            }
            .onAppear {
                if directory.isEmpty {
                    isShowingHomeView = true
                }
            }
            .onChange(of: directory) { newValue in
                // If directory is changed save to recent project filepaths
                RecentProjectHelper.recentProjectFilepaths.append(newValue)
                
                if directory.isEmpty {
                    isShowingHomeView = true
                } else {
                    isShowingHomeView = false
                }
            }
            .task {
                // Start StoreKit listener in IAPManager
                IAPManager.startStoreKitListener()
                
                // Get and ensure authToken
                let authToken: String
                do {
                    authToken = try await AuthHelper.ensure()
                } catch {
                    // TODO: Handle Errors
                    print("Error ensuring authToken in AICodingHelperApp... \(error)")
                    return
                }
                
                // Update remainingUpdater
                do {
                    try await remainingUpdater.update(authToken: authToken)
                } catch {
                    // TODO: Handle Errors
                    print("Error updating remaining in AICodingHelperApp... \(error)")
                }
                
                // Update constants
                do {
                    try await ConstantsHelper.updateImportantConstants()
                } catch {
                    // TODO: Handle Errors
                    print("Error updating constants in AICodingHelperApp... \(error)")
                }
                
                // Refresh productUpdater
                await productUpdater.refresh()
            }
        }
        .commands {
            AICodingHelperAppCommands(
                availableCommands: .all,
                isShowingNewAIProject: $isShowingCreateAIProject,
                isShowingNewBlankProject: $isShowingCreateBlankProject,
                isShowingNewAIFilePopup: $popupShowingCreateAIFile,
                isShowingNewBlankFilePopup: $popupShowingCreateBlankFile,
                isShowingNewFolderPopup: $popupShowingCreateFolder,
                isShowingOpenFileImporter: $isShowingOpenProjectImporter)
        }
        .defaultSize(width: 1000.0, height: 600.0)
        Settings {
            SettingsView()
                .environmentObject(codeEditorSettingsViewModel)
        }
    }
    
}
