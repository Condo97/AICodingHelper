//
//  AICodingHelperApp.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 6/26/24.
//

import SwiftUI

@main
struct AICodingHelperApp: App {
    
    
    @Environment(\.undoManager) private var undoManager
    
    @StateObject private var focusViewModel: FocusViewModel = FocusViewModel()
    @StateObject private var remainingUpdater: RemainingUpdater = RemainingUpdater()
    @StateObject private var undoUpdater: UndoUpdater = UndoUpdater()
    
    @State private var directory: String = ""
    
    @State private var popupShowingCreateAIFile = false
    @State private var popupShowingCreateBlankFile = false
    @State private var popupShowingCreateFolder = false
    @State private var isShowingCreateAIProject = false
    @State private var isShowingCreateBlankProject = false
    @State private var isShowingOpenFileImporter = false
    

    var body: some Scene {
        WindowGroup {
            ZStack {
                if directory.isEmpty {
                    HomeView(
                        filepath: $directory,
                        isShowingCreateAIProject: $isShowingCreateAIProject,
                        isShowingCreateBlankProject: $isShowingCreateBlankProject,
                        isShowingOpenFileImporter: $isShowingOpenFileImporter)
                } else {
                    MainView(
                        directory: $directory,
                        popupShowingCreateAIFile: $popupShowingCreateAIFile,
                        popupShowingCreateBlankFile: $popupShowingCreateBlankFile,
                        popupShowingCreateFolder: $popupShowingCreateFolder)
                }
            }
            .grantedPermissionsDirectoryCreator(isPresented: $isShowingCreateBlankProject, projectFolderPath: $directory)
            .grantedPermissionsDirectoryImporter(isPresented: $isShowingOpenFileImporter, filepath: $directory)
            .aiProjectCreatorPopup(isPresented: $isShowingCreateAIProject, baseFilepath: $directory)
            .environmentObject(focusViewModel)
            .environmentObject(remainingUpdater)
            .environmentObject(undoUpdater)
            .onChange(of: directory) { newValue in
                // If directory is changed save to recent project folders
                UserDefaultsHelper.recentProjectFolders.append(newValue)
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
                baseFilepath: $directory,
                isShowingNewAIProject: $isShowingCreateAIProject,
                isShowingNewBlankProject: $isShowingCreateBlankProject,
                isShowingNewAIFilePopup: $popupShowingCreateAIFile,
                isShowingNewBlankFilePopup: $popupShowingCreateBlankFile,
                isShowingNewFolderPopup: $popupShowingCreateFolder,
                isShowingOpenFileImporter: $isShowingOpenFileImporter)
        }
    }
    
}
