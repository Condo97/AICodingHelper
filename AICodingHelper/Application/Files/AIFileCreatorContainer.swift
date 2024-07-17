//
//  AIFileCreatorContainer.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/7/24.
//

import SwiftUI

struct AIFileCreatorContainer: View {
    
    @Binding var isPresented: Bool
    @State var baseFilepath: String
    @State var referenceFilepaths: [String] // This is a state because if it is changed it should not propogate to the parent
    @ObservedObject var progressTracker: ProgressTracker
    
    
    private static let fileGeneratorSystemMessage = "You are an AI coding helper service in an IDE so you must format all your responses in code that would be valid in an IDE. Do not include ```LanguageName or ``` to denote code. You only respond with code that is valid in that language. You only respond to the one requested file. All files will be provided in turn, so therefore you will respond to each individually to preserve correct formatting to the IDE since it is looking to receive one file."
    
    
    @EnvironmentObject private var activeSubscriptionUpdater: ActiveSubscriptionUpdater
    @EnvironmentObject private var remainingUpdater: RemainingUpdater
    
    @State private var isLoading: Bool = false
    
    @State private var newFileName: String = ""
    @State private var userPrompt: String = ""
    
    
    var body: some View {
        AIFileCreatorView(
            newFileName: $newFileName,
            referenceFilepaths: $referenceFilepaths,
            userPrompt: $userPrompt,
            onCancel: {
                // Dismiss
                withAnimation {
                    isPresented = false
                }
            },
            onSubmit: {
                Task {
                    // Generate File
                    do {
                        try await generateFile()
                    } catch {
                        // TODO: Handle Errors
                        print("Error generating file in AIFileCreatorContainer... \(error)")
                        return
                    }
                    
                    // Dismiss
                    withAnimation {
                        isPresented = false
                    }
                }
            })
        .overlay { // TODO: This could be an alert
            if isLoading {
                ZStack {
                    Colors.foreground
                        .opacity(0.4)
                    
                    VStack {
                        Text("Creating File...")
                        
                        ProgressView()
                            .tint(Colors.foregroundText)
                    }
                }
            }
        }
    }
    
    
    func generateFile() async throws {
        // Defer setting isLoading to false
        defer {
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
        
        // Set isLoading to true
        await MainActor.run {
            self.isLoading = true
        }
        
        // Ensure authToken
        let authToken = try await AuthHelper.ensure()
        
        // Get openAIKey
        let openAIKey = activeSubscriptionUpdater.openAIKey
        
        // Get newFileFilepath from newFileName and baseFilepath
        let newFileFilepath = URL(fileURLWithPath: baseFilepath).appendingPathComponent(newFileName, conformingTo: .text).path
        
        // Create systemMessage
        let systemMessage: String = AIFileCreatorContainer.fileGeneratorSystemMessage
        
        // Create instructions
        let instructions: String = {
            var instructions: [String] = []
            
            instructions.append("Create the file \(newFileName)") // TODO: Is this necessary?
            
            if !userPrompt.isEmpty {
                instructions.append("Add the following functionality to \(newFileName).")
                instructions.append(userPrompt)
            }
            
            if !referenceFilepaths.isEmpty {
                instructions.append("Use these files as reference")
                instructions.append(referenceFilepaths.map({FilePrettyPrinter.getFileContent(filepath: $0)}).joined(separator: "\n"))
            }
            
            return instructions.joined(separator: "\n")
        }()
        
        // Create CodeGenerationPlan with create and edit action for new file
        let codeGenerationPlan = CodeGenerationPlan(
            model: .GPT4o,
            editActionSystemMessage: systemMessage,
            instructions: instructions,
            copyCurrentFilesToTempFiles: false,
            planFC: PlanCodeGenerationFC(
                steps: [
                    PlanCodeGenerationFC.Step(
                        index: 0,
                        action: .create,
                        filepath: newFileFilepath,
                        editInstructions: nil,
                        referenceFilepaths: nil),
                    PlanCodeGenerationFC.Step(
                        index: 1,
                        action: .edit,
                        filepath: newFileFilepath,
                        editInstructions: nil,
                        referenceFilepaths: referenceFilepaths)
                ]))
        
        // Execute CodeGenerationPlan
        try await CodeGenerationPlanExecutor().generateAndRefactor(
            authToken: authToken,
            openAIKey: openAIKey,
            plan: codeGenerationPlan,
            progressTracker: progressTracker)
        
        // Update remaining
        try await remainingUpdater.update(authToken: authToken)
    }
    
}


extension View {
    
    func aiFileCreatorPopup(isPresented: Binding<Bool>, baseFilepath: String, referenceFilepaths: [String]) -> some View {
        self
            .sheet(isPresented: isPresented) {
                AIFileCreatorContainer(
                    isPresented: isPresented,
                    baseFilepath: baseFilepath,
                    referenceFilepaths: referenceFilepaths,
                    progressTracker: ProgressTracker())
            }
    }
    
}


#Preview {
    
    AIFileCreatorContainer(
        isPresented: .constant(true),
        baseFilepath: "~/Downloads/test_dir",
        referenceFilepaths: [],
        progressTracker: ProgressTracker()
    )
    
}
