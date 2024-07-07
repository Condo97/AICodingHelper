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
    
    @State private var directory: String?
    
    @State private var popupShowingCreateAIFile = false
    @State private var popupShowingCreateBlankFile = false
    @State private var popupShowingCreateFolder = false
    
    var directoryUnwrapped: Binding<String> {
        Binding(
            get: {
                directory ?? ""
            },
            set: { value in
                directory = value
            })
    }
    

    var body: some Scene {
        WindowGroup {
            ZStack {
                if let directory = directory {
                    MainView(
                        directory: directoryUnwrapped,
                        popupShowingCreateAIFile: $popupShowingCreateAIFile,
                        popupShowingCreateBlankFile: $popupShowingCreateBlankFile,
                        popupShowingCreateFolder: $popupShowingCreateFolder)
                } else {
                    FilePickerView(filePath: $directory)
                }
            }
            .environmentObject(focusViewModel)
            .environmentObject(remainingUpdater)
            .environmentObject(undoUpdater)
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
                baseFilepath: directoryUnwrapped,
                isShowingNewAIFilePopup: $popupShowingCreateAIFile,
                isShowingNewBlankFilePopup: $popupShowingCreateBlankFile,
                isShowingNewFolderPopup: $popupShowingCreateFolder)
        }
    }
    
}
