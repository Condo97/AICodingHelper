//
//  FileBrowserView.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/1/24.
//

import SwiftUI

struct FileBrowserView: View {
    
    @Binding var baseDirectory: String
    @Binding var openTab: CodeViewModel?
    @Binding var openTabs: [CodeViewModel]
    
    
    private static let multiFileParentFileSystemName = "TempSelection"
    
    @StateObject private var wideScopeChatGenerator: WideScopeChatGenerator = WideScopeChatGenerator()
    
    @State private var copyCurrentFilesToTempFiles: Bool = true
    @State private var currentWideScope: Scope?
    @State private var selectedFilepaths: [String] = []
    
    
    var body: some View {
        ZStack {
            // File Browser
            TabAddingFileSystemView(
                directory: $baseDirectory,
                selectedFilepaths: $selectedFilepaths,
                openTab: $openTab,
                openTabs: $openTabs)
            
            VStack {
                Spacer()
                HStack {
                    // Wide Scope Controls
                    WideScopeControlsView(
                        scope: $currentWideScope,
                        selectedFilepaths: $selectedFilepaths,
                        onSubmit: { actionType in
                            // If selectedFilepaths contains at least one item refactor files with it or them, otherwise refactor project TODO: Maybe make this implementation better in regards to doing entire project refactor
                            if selectedFilepaths.count > 0 {
                                // Get rootFile using FileSystem from with the first selected path if there is only one item and FileSystem from with all selected paths if there are multiple. The reason to use the different function is because from without paths and parent name will make it the root node and fetch all the items whereas with paths it will create a parent with parent name to hold the paths and then assemble the FileSystem normally
                                guard let rootFile = selectedFilepaths.count == 1 ? FileSystem.from(path: selectedFilepaths[0]) : FileSystem.from(
                                    parentName: FileBrowserView.multiFileParentFileSystemName,
                                    paths: selectedFilepaths) else {
                                    // TODO: Handle Errors
                                    print("Error unwrapping rootFile in FileBrowserView!")
                                    return
                                }
                                
                                refactorFiles(
                                    action: actionType,
                                    userInput: nil, // TODO: Add this
                                    rootDirectoryPath: NSString(string: baseDirectory).expandingTildeInPath,
                                    rootFile: rootFile,
                                    alternativeContextFiles: nil,
                                    copyCurrentFilesToTempFiles: copyCurrentFilesToTempFiles)
                            } else {
                                // Refactor project
                                refactorProject(
                                    action: actionType,
                                    userInput: nil, // TODO: Add this
                                    rootDirectoryPath: NSString(string: baseDirectory).expandingTildeInPath,
                                    copyCurrentFilesToTempFiles: copyCurrentFilesToTempFiles)
                            }
                        })
                    .padding()
                    .padding(.bottom)
                    .padding(.bottom)
                    Spacer()
                }
            }
        }
    }
    
    
    func refactorProject(action: ActionType, userInput: String?, rootDirectoryPath: String, copyCurrentFilesToTempFiles: Bool) {
        // Create FileSystem from root directory, otherwise reutrn
        guard let rootDirectoryFileSystem = FileSystem.from(path: rootDirectoryPath) else {
            // TODO: Handle Errors
            print("Error unwrapping baseDirectoryFileSystem in FileBrowserView!")
            return
        }
        
        // Refactor Files
        refactorFiles(
            action: action,
            userInput: userInput,
            rootDirectoryPath: rootDirectoryPath,
            rootFile: rootDirectoryFileSystem,
            alternativeContextFiles: nil,
            copyCurrentFilesToTempFiles: copyCurrentFilesToTempFiles)
    }
    
    func refactorFiles(action: ActionType, userInput: String?, rootDirectoryPath: String, rootFile: FileSystem, alternativeContextFiles: FileSystem?, copyCurrentFilesToTempFiles: Bool) {
        Task {
            // Create additionalInput from userInput TODO: Add this
            let additionalInput = userInput
            
            // Ensure authToken
            let authToken: String
            do {
                authToken = try await AuthHelper.ensure()
            } catch {
                // TODO: Handle Errors
                print("Error ensuring authToken in MainView... \(error)")
                return
            }
            
            // Refactor files
            do {
                try await wideScopeChatGenerator.refactorFiles(
                    authToken: authToken,
                    model: .GPT4o,
                    action: action,
                    additionalInput: additionalInput,
                    rootDirectoryPath: rootDirectoryPath,
                    rootFile: rootFile,
                    alternativeContextFiles: alternativeContextFiles,
                    copyCurrentFilesToTempFiles: copyCurrentFilesToTempFiles)
            }
        }
    }
    
}

#Preview {
    
    FileBrowserView(
        baseDirectory: .constant("~/Downloads/test_dir"),
        openTab: .constant(nil),
        openTabs: .constant([]))
    
}
