//
//  CodeGeneratorControlsContainer.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/20/24.
//

import SwiftUI

struct CodeGeneratorControlsContainer: View {
    
    @Binding var scope: Scope
    @Binding var rootFilepath: String
    @ObservedObject var progressTracker: ProgressTracker
    @ObservedObject var focusViewModel: FocusViewModel
    @ObservedObject var tabsViewModel: TabsViewModel
    @Binding var fileBrowserSelectedFilepaths: [String]
    @Binding var isLoading: Bool
    
    @Environment(\.undoManager) private var undoManager
    
    @EnvironmentObject private var activeSubscriptionUpdater: ActiveSubscriptionUpdater
    @EnvironmentObject private var remainingUpdater: RemainingUpdater
    
    @State private var alertShowingInvalidOpenAIKey: Bool = false
    
    @State private var currentDiscussion: Discussion?
    
    @State private var isLoadingDiscussion: Bool = false
    
//    var discussionBindingUnwrapped: Binding<Discussion> {
//        Binding(
//            get: {
//                currentDiscussion ?? Discussion(chats: [])
//            },
//            set: { value in
//                currentDiscussion = value
//            })
//    }
    
    var isShowingCurrentDiscussion: Binding<Bool> {
        Binding(
            get: {
                currentDiscussion != nil
            },
            set: { value in
                if !value {
                    currentDiscussion = nil
                }
            })
    }
    
    var body: some View {
        CodeGeneratorControlsView(
            scope: $scope,
            focusViewModel: focusViewModel,
            selectedFilepaths: $fileBrowserSelectedFilepaths,
            onSubmit: { actionType, userInput, referenceFilepaths, generateOptions in
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
                        alternateContextFilepaths.append(rootFilepath)
                    }
                    
                    // Do generation by scope
                    switch scope {
                    case .project:
                        // Generate with wide scope generator using single object array with directory as filepaths
                        do {
                            // Defer setting isLoading to false
                            defer {
                                DispatchQueue.main.async {
                                    self.isLoading = false
                                }
                            }
                            
                            // Set isLoading to true
                            DispatchQueue.main.async {
                                self.isLoading = true
                            }
                            
                            // Create instructions from action aiPrompt and userInput
                            let instructions = actionType.aiPrompt + (userInput.isEmpty ? "" : "\n" + userInput)
                            
                            // Generate and append generate code FC to discussion
                            await generateAndAppendGenerateCodeFCToDiscussion(
                                instructions: instructions,
                                referenceFilepaths: try FileManager.default.contentsOfDirectory(atPath: rootFilepath),
                                copyCurrentFilesToTempFiles: generateOptions.contains(.copyCurrentFilesToTempFiles))
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
                            // Defer setting isLoading to false
                            defer {
                                DispatchQueue.main.async {
                                    self.isLoading = false
                                }
                            }
                            
                            // Set isLoading to true
                            DispatchQueue.main.async {
                                self.isLoading = true
                            }
                            
                            // Create instructions from action aiPrompt and userInput
                            let instructions = actionType.aiPrompt + (userInput.isEmpty ? "" : "\n" + userInput)
                            
                            // Generate and append generate code FC to discussion
                            await generateAndAppendGenerateCodeFCToDiscussion(
                                instructions: instructions,
                                referenceFilepaths: referenceFilepaths,
                                copyCurrentFilesToTempFiles: generateOptions.contains(.copyCurrentFilesToTempFiles))
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
                                context: referenceFilepaths.map({FilePrettyPrinter.getFileContent(relativeFilepath: $0, rootFilepath: rootFilepath)}) + [], // TODO: Use project as context and stuff
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
                            // Defer setting isLoading to false
                            defer {
                                DispatchQueue.main.async {
                                    self.isLoading = false
                                }
                            }
                            
                            // Set isLoading to true
                            DispatchQueue.main.async {
                                self.isLoading = true
                            }
                            
                            // Create instructions from action aiPrompt and userInput
                            let instructions = actionType.aiPrompt + (userInput.isEmpty ? "" : "\n" + userInput)
                            
                            // Generate and append generate code FC to discussion
                            await generateAndAppendGenerateCodeFCToDiscussion(
                                instructions: instructions,
                                referenceFilepaths: referenceFilepaths,
                                copyCurrentFilesToTempFiles: generateOptions.contains(.copyCurrentFilesToTempFiles))
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
                                context: referenceFilepaths.map({FilePrettyPrinter.getFileContent(relativeFilepath: $0, rootFilepath: rootFilepath)}) + [],
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
        .alert("Invalid OpenAI Key", isPresented: $alertShowingInvalidOpenAIKey, actions: {
            Button("Close") {
                
            }
        }, message: {
            Text("Your Open AI API Key is invalid and your plan will be used until it is updated. If you believe this is an error please report it!")
        })
        .sheet(isPresented: isShowingCurrentDiscussion, content: {// discussion in
            VStack {
                if let currentDiscussion = currentDiscussion {
                    DiscussionView(
                        rootFilepath: $rootFilepath,
                        discussion: currentDiscussion,
                        isLoading: $isLoadingDiscussion)
                        .padding()
                }
                
                HStack {
                    Spacer()
                    
                    Button("Done") {
                        currentDiscussion = nil
                    }
                    .keyboardShortcut(.cancelAction)
                }
                .padding(8)
            }
            .frame(minWidth: 350.0, idealWidth: 1050.0, minHeight: 300.0, idealHeight: 800.0)
        })
    }
    
    
    func generateAndAppendGenerateCodeFCToDiscussion(instructions: String, referenceFilepaths: [String], copyCurrentFilesToTempFiles: Bool) async {
        // Defer setting isLoading to false
        defer {
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
        
        // Set isLoading to true
        await MainActor.run {
            isLoading = true
        }
        
        // If discussion is nil set to new discussion
        if currentDiscussion == nil {
            currentDiscussion = Discussion(chats: [])
        }
        
        // Append user chat to currentDiscussion
        currentDiscussion?.chats.append(
            Chat(
                role: .user,
                message: instructions,
                referenceFilepaths: referenceFilepaths))
        
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
        
        // Generate and append to discussion
        do {
            guard let generateCodeFC = try await CodeGenerator.generateCode(
                authToken: authToken,
                openAIKey: openAIKey,
                model: .GPT4o,
                instructions: instructions,
                rootFilepath: rootFilepath,
                selectedFilepaths: referenceFilepaths,
                copyCurrentFilesToTempFiles: copyCurrentFilesToTempFiles) else {
                // TODO: Handle Errors
                print("Could not unwrap generateCodeFC in CodeGeneratorControlsContainer!")
                return
            }
            
            currentDiscussion?.chats.append(
                Chat(
                    role: .assistant,
                    message: generateCodeFC))
//                        progressTracker: progressTracker)
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

#Preview {
    
    CodeGeneratorControlsContainer(
        scope: .constant(.project),
        rootFilepath: .constant("~/Downloads/test_dir"),
        progressTracker: ProgressTracker(),
        focusViewModel: FocusViewModel(),
        tabsViewModel: TabsViewModel(),
        fileBrowserSelectedFilepaths: .constant([]),
        isLoading: .constant(true)
    )
    
}
