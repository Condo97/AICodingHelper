//
//  GrantedPermissionsDirectoryCreator.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/7/24.
//

import Foundation
import SwiftUI

struct GrantedPermissionsDirectoryCreator: ViewModifier {
    
    @Binding var isPresented: Bool
    @Binding var projectFolderPath: String
    
    func body(content: Content) -> some View {
        content
            .onChange(of: isPresented) { newValue in
                if newValue {
                    DispatchQueue.main.async {
                        createProjectFolder()
                        
                        isPresented = false
                    }
                }
            }
    }
    
    private func createProjectFolder() {
        let dialog = NSSavePanel()
        dialog.title = "Create Project Folder"
        dialog.message = "Select a location to create the project folder"
        dialog.prompt = "Create"
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.canCreateDirectories = true
        dialog.allowedContentTypes = [.folder]
        dialog.nameFieldStringValue = "NewProject"
        
        if dialog.runModal() == .OK, let url = dialog.url {
            do {
//                let folderUrl = url.appendingPathComponent(dialog.nameFieldStringValue)
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
                projectFolderPath = url.path
            } catch {
                print("Failed to create directory: \(error.localizedDescription)")
            }
        }
    }
}


extension View {
    
    func grantedPermissionsDirectoryCreator(isPresented: Binding<Bool>, projectFolderPath: Binding<String>) -> some View {
        self
            .modifier(GrantedPermissionsDirectoryCreator(isPresented: isPresented, projectFolderPath: projectFolderPath))
    }
}
