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
    
    @StateObject private var undoUpdater: UndoUpdater = UndoUpdater()
    

    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(undoUpdater)
                .task {
                    do {
                        try await AuthHelper.ensure()
                    } catch {
                        // TODO: Handle Errors
                        print("Error ensuring authToken in AICodingHelperApp... \(error)")
                    }
                }
        }
    }
    
}
