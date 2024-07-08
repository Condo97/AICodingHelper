//
//  AIProjectCreatorContainer.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/8/24.
//

import SwiftUI

struct AIProjectCreatorContainer: View {
    
    @Binding var isPresented: Bool
    @Binding var baseFilepath: String
    
    // Basically the goal is to create a code generation plan to create a project, we will need to generate a plan and then generate the project so there may need to be a popup confirming how many tokens it will be, or maybe it can just be on that window like the submit button could be diabled and be changed with a different word like it could say "Next...", which will then disable the button and either an alert will pop up confirming the generation or the next button will become "Generate" and the token count will appear to the left but idk I like the first one better lol
    
    @EnvironmentObject private var remainingUpdater: RemainingUpdater
    
    private static let generatePlanBaseInstructions: String = "Create a plan to create and code a project for the specified requirements."
    private static let createProjectSystemMessage: String = "You are an AI coding helper service in an IDE so you must format all your responses in code that would be valid in an IDE. Do not include ```LanguageName or ``` to denote code. You only respond with code that is valid in that language. You only respond to the one requested file. All files will be provided in turn, so therefore you will respond to each individually to preserve correct formatting to the IDE since it is looking to receive one file."// "You are creating a project in code for the specified language formatted for an IDE."
    private static let additionalTokensForEstimationPerFile: Int = Constants.Additional.additionalTokensForEstimationPerFile
    
    @State private var referenceFilepaths: [String] = []
    @State private var language: String = ""
    @State private var userPrompt: String = ""
    
    @State private var plan: CodeGenerationPlan?
    @State private var createProjectEstimatedTokens: Int?
    
    @State private var isLoadingPlanProject: Bool = false
    @State private var isLoadingCreateProject: Bool = false
    
    @State private var alertShowingConfirmCodeGeneration: Bool = false
    
    var body: some View {
        AIProjectCreatorView(
            baseProjectFilepath: $baseFilepath,
            referenceFilepaths: $referenceFilepaths,
            language: $language,
            userPrompt: $userPrompt,
            onCancel: {
                // Dismiss
                DispatchQueue.main.async {
                    withAnimation {
                        isPresented = false
                    }
                }
            },
            onSubmit: {
                Task {
                    // Defer setting isLoadingPlanProject to false
                    defer {
                        DispatchQueue.main.async {
                            self.isLoadingPlanProject = false
                        }
                    }
                    
                    // Set isLoadingPlanProject to true
                    await MainActor.run {
                        isLoadingPlanProject = true
                    }
                    
                    // Ensure authToken
                    let authToken: String
                    do {
                        authToken = try await AuthHelper.ensure()
                    } catch {
                        // TODO: Handle Errors
                        print("Error ensuring authToken in AIProjectCreatorContainer... \(error)")
                        return
                    }
                    
                    // Get instructions from generatePlanBaseInstructions + "\nProject Base Filepath " + baseFilepath + "\nProject Language " + language + "\n" + userPrompt or blank if empty
                    let instructions = AIProjectCreatorContainer.generatePlanBaseInstructions + "\nProject Base Filepath " + baseFilepath + "\nProject Language " + language + (userPrompt.isEmpty ? "" : "\n" + userPrompt)
                    
                    // Generate plan
                    guard let plan = try await CodeGenerationPlanner.makePlan(
                        authToken: authToken,
                        model: .GPT4o,
                        editActionSystemMessage: AIProjectCreatorContainer.createProjectSystemMessage,
                        instructions: instructions,
                        selectedFilepaths: referenceFilepaths,
                        copyCurrentFilesToTempFiles: false) else {
                        // TODO: Handle Errors
                        print("Could not unwrap plan after generating in AIProjectCreatorContainer!")
                        return
                    }
                    
                    // Get estimated tokens
                    let estimatedTokens = await TokenCalculator.getEstimatedTokens(
                        authToken: authToken,
                        codeGenerationPlan: plan)
                    
                    DispatchQueue.main.async {
                        // Set planFC and createProjectEstimatedTokens and show confirm code generation alert
                        self.plan = plan
                        self.createProjectEstimatedTokens = estimatedTokens
                        self.alertShowingConfirmCodeGeneration = true
                    }
                    
                }
            })
        .overlay {
            if isLoadingCreateProject || isLoadingPlanProject {
                ZStack {
                    Colors.foreground
                        .opacity(0.4)
                    
                    VStack {
                        if isLoadingPlanProject {
                            Text("Generating AI Project Plan...")
                        } else if isLoadingCreateProject {
                            Text("Creating AI Project...")
                        } else {
                            Text("Loading...")
                        }
                        
                        ProgressView()
                            .tint(Colors.foregroundText)
                    }
                }
            }
        }
        .alert("Approve AI Task", isPresented: $alertShowingConfirmCodeGeneration, actions: {
            Button("Cancel", role: .cancel) {
                
            }
            
            Button("Start") {
                Task {
                    // Create project
                    await createProject()
                    
                    // Dismiss
                    await MainActor.run {
                        isPresented = false
                    }
                }
            }
        }, message: {
            Text("Task Details:\n")
//            +
//            Text("• \(currentWideScopeChatGenerationTask?.filepathCodeGenerationPrompts.count ?? -1) Files\n")
            +
            Text("• \(createProjectEstimatedTokens ?? -1) Est. Tokens")
        })
    }
    
    
    func createProject() async {
        guard let plan = plan,
              let createProjectEstimatedTokens = createProjectEstimatedTokens else {
            // TODO: Handle Errors
            print("Could not unwrap plan or createProjectEstimatedTokens in AIProjectCreatorContainer!")
            return
        }
        
        guard createProjectEstimatedTokens + AIProjectCreatorContainer.additionalTokensForEstimationPerFile < remainingUpdater.remaining else {
            // TODO: Handle Errors
            print("Current code generation plan token estimation plus additional tokens for estimation per file exceeds remaining tokens!")
            return
        }
        
        // Defer setting isLoadingCreateProject to false
        defer {
            DispatchQueue.main.async {
                self.isLoadingCreateProject = false
            }
        }
        
        // Set isLoadingCreateProject to true
        await MainActor.run {
            isLoadingCreateProject = true
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
        
        // Generate and refactor
        do {
            try await CodeGenerationPlanExecutor.generateAndRefactor(
                authToken: authToken,
                plan: plan)
        } catch {
            // TODO: Handle Errors
            print("Error generating and refactoring çode in MainView... \(error)")
        }
    }
    
}

#Preview {
    
    AIProjectCreatorContainer(
        isPresented: .constant(true),
        baseFilepath: .constant("~/Downloads/test_dir")
    )
    
}
