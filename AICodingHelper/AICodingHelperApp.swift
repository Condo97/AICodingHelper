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
    
    @StateObject private var codeEditorSettingsViewModel: CodeEditorSettingsViewModel = CodeEditorSettingsViewModel()
    @StateObject private var focusViewModel: FocusViewModel = FocusViewModel()
    @StateObject private var remainingUpdater: RemainingUpdater = RemainingUpdater()
    @StateObject private var undoUpdater: UndoUpdater = UndoUpdater()
    
    @State private var directory: String = ""
    
    @State private var popupShowingCreateAIFile = false
    @State private var popupShowingCreateBlankFile = false
    @State private var popupShowingCreateFolder = false
    @State private var isShowingCreateAIProject = false
    @State private var isShowingCreateBlankProject = false
    @State private var isShowingOpenProjectImporter = false
    

    var body: some Scene {
        WindowGroup {
            ZStack {
                if directory.isEmpty {
                    HomeView(
                        filepath: $directory,
                        isShowingCreateAIProject: $isShowingCreateAIProject,
                        isShowingCreateBlankProject: $isShowingCreateBlankProject,
                        isShowingOpenFileImporter: $isShowingOpenProjectImporter)
                } else {
                    MainView(
                        directory: $directory,
                        popupShowingCreateAIFile: $popupShowingCreateAIFile,
                        popupShowingCreateBlankFile: $popupShowingCreateBlankFile,
                        popupShowingCreateFolder: $popupShowingCreateFolder)
                }
            }
            .grantedPermissionsDirectoryCreator(isPresented: $isShowingCreateBlankProject, projectFolderPath: $directory)
            .grantedPermissionsDirectoryImporter(isPresented: $isShowingOpenProjectImporter, filepath: $directory)
            .aiProjectCreatorPopup(isPresented: $isShowingCreateAIProject, baseFilepath: $directory)
            .environmentObject(codeEditorSettingsViewModel)
            .environmentObject(focusViewModel)
            .environmentObject(remainingUpdater)
            .environmentObject(undoUpdater)
            .onChange(of: directory) { newValue in
                // If directory is changed save to recent project filepaths
                RecentProjectHelper.recentProjectFilepaths.append(newValue)
            }
            .task {
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
        Settings {
            SettingsView()
                .environmentObject(codeEditorSettingsViewModel)
        }
    }
    
}
