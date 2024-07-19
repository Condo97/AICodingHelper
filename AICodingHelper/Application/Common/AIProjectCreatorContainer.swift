//
//  AIProjectCreatorContainer.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/8/24.
//

import SwiftUI

struct AIProjectCreatorContainer: View {
    
    @Binding var isPresented: Bool
    @Binding var rootFilepath: String
    
    // Basically the goal is to create a code generation plan to create a project, we will need to generate a plan and then generate the project so there may need to be a popup confirming how many tokens it will be, or maybe it can just be on that window like the submit button could be diabled and be changed with a different word like it could say "Next...", which will then disable the button and either an alert will pop up confirming the generation or the next button will become "Generate" and the token count will appear to the left but idk I like the first one better lol
    
    @EnvironmentObject private var activeSubscriptionUpdater: ActiveSubscriptionUpdater
    @EnvironmentObject private var remainingUpdater: RemainingUpdater
    
    private static let generatePlanBaseInstructions: String = "Create a plan to create and code a project for the specified requirements."
    private static let createProjectSystemMessage: String = "You are an AI coding helper service in an IDE so you must format all your responses in code that would be valid in an IDE. Do not include ```LanguageName or ``` to denote code. You only respond with code that is valid in that language. You only respond to the one requested file. All files will be provided in turn, so therefore you will respond to each individually to preserve correct formatting to the IDE since it is looking to receive one file. You may include messages in comments if the langauge supports comments."// "You are creating a project in code for the specified language formatted for an IDE."
    private static let additionalTokensForEstimationPerFile: Int = Constants.Additional.additionalTokensForEstimationPerFile
    
    @StateObject private var progressTracker: ProgressTracker = ProgressTracker()
    
    @State private var referenceFilepaths: [String] = []
    @State private var language: String = ""
    @State private var userPrompt: String = ""
    
//    @State private var plan: CodeGenerationPlan?
//    @State private var createProjectEstimatedTokens: Int?
    @State private var currentCodeGenerationPlan: CodeGenerationPlan?
    @State private var currentCodeGenerationPlanTokenEstimation: Int?
    
    @State private var isLoadingPlanProject: Bool = false
    @State private var isLoadingCreateProject: Bool = false
    
    @State private var alertShowingConfirmCodeGeneration: Bool = false
    
    
    var body: some View {
        AIProjectCreatorView(
            baseProjectFilepath: $rootFilepath,
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
                    
                    // Get openAIKey
                    let openAIKey = activeSubscriptionUpdater.openAIKeyIsValid ? activeSubscriptionUpdater.openAIKey : nil
                    
                    // Get instructions from generatePlanBaseInstructions + "\nProject Language " + language + "\n" + userPrompt or blank if empty
                    let instructions = AIProjectCreatorContainer.generatePlanBaseInstructions + "\nProject Language " + language + (userPrompt.isEmpty ? "" : "\n" + userPrompt)
                    
                    // Generate plan
                    let plan: CodeGenerationPlan
                    do {
                        guard let createdPlan = try await CodeGenerationPlanner.makePlan(
                            authToken: authToken,
                            openAIKey: openAIKey,
                            model: .GPT4o,
                            editActionSystemMessage: AIProjectCreatorContainer.createProjectSystemMessage,
                            instructions: instructions,
                            rootFilepath: rootFilepath,
                            selectedFilepaths: referenceFilepaths,
                            copyCurrentFilesToTempFiles: false) else {
                            // TODO: Handle Errors
                            print("Could not unwrap plan after generating in AIProjectCreatorContainer!")
                            return
                        }
                        
                        plan = createdPlan
                    } catch {
                        // TODO: Handle Errors
                        print("Error making plan in AIProjectCreatorContainer... \(error)")
                        return
                    }
                    
                    // Get estimated tokens
                    let estimatedTokens = await TokenCalculator.getEstimatedTokens(
                        authToken: authToken,
                        codeGenerationPlan: plan)
                    
                    DispatchQueue.main.async {
                        // Set planFC and createProjectEstimatedTokens and show confirm code generation alert
                        self.currentCodeGenerationPlan = plan
                        self.currentCodeGenerationPlanTokenEstimation = estimatedTokens
                        self.alertShowingConfirmCodeGeneration = true
                    }
                    
                }
            })
        .disabled(isLoadingCreateProject || isLoadingPlanProject)
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
        .sheet(isPresented: $alertShowingConfirmCodeGeneration) {
            var currentCodeGenerationPlanUnwrappedBinding: Binding<CodeGenerationPlan> {
                Binding(
                    get: {
                        currentCodeGenerationPlan ?? CodeGenerationPlan(
                            model: .GPT4o,
                            rootFilepath: "///--!!!!",
                            editActionSystemMessage: "",
                            instructions: "",
                            copyCurrentFilesToTempFiles: true,
                            planFC: PlanCodeGenerationFC(steps: []))
                    },
                    set: { value in
                        currentCodeGenerationPlan = value
                    })
            }
            ApprovePlanView(
                plan: currentCodeGenerationPlanUnwrappedBinding,
                tokenEstimation: $currentCodeGenerationPlanTokenEstimation,
                onCancel: {
                    // Set current code generation plan and its token estimation to nil
                    currentCodeGenerationPlan = nil
                    currentCodeGenerationPlanTokenEstimation = nil
                    
                    // Dismiss
                    alertShowingConfirmCodeGeneration = false
                },
                onStart: {
                    Task {
                        // Create project
                        await createProject()
                    }
                    
                    // Dismiss
                    alertShowingConfirmCodeGeneration = false
                })
        }
    }
    
    
    func createProject() async {
        guard let currentCodeGenerationPlan = currentCodeGenerationPlan,
              let currentCodeGenerationPlanTokenEstimation = currentCodeGenerationPlanTokenEstimation else {
            // TODO: Handle Errors
            print("Could not unwrap plan or createProjectEstimatedTokens in AIProjectCreatorContainer!")
            return
        }
        
        guard currentCodeGenerationPlanTokenEstimation + AIProjectCreatorContainer.additionalTokensForEstimationPerFile < remainingUpdater.remaining else {
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
        
        // Get openAIKey
        let openAIKey = activeSubscriptionUpdater.openAIKeyIsValid ? activeSubscriptionUpdater.openAIKey : nil
        
        // Generate and refactor
        do {
            try await CodeGenerationPlanExecutor().generateAndRefactor(
                authToken: authToken,
                openAIKey: openAIKey,
                plan: currentCodeGenerationPlan,
                progressTracker: progressTracker)
        } catch {
            // TODO: Handle Errors
            print("Error generating and refactoring çode in MainView... \(error)")
        }
        
        // Dismiss
        await MainActor.run {
            isPresented = false
        }
    }
    
}

#Preview {
    
    AIProjectCreatorContainer(
        isPresented: .constant(true),
        rootFilepath: .constant("~/Downloads/test_dir")
    )
    
}
