//
//  AICodingHelperApp.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 6/26/24.
//

import SwiftUI

@main
struct AICodingHelperApp: App {
    

    var body: some Scene {
        WindowGroup {
            MainView()
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
