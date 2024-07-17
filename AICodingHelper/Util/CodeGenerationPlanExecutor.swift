//
//  PlannedCodeGenerationRefactorService.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/6/24.
//

import Foundation


class CodeGenerationPlanExecutor {
    
    private var previousEditResponses: [String] = []

    func generateAndRefactor(authToken: String, openAIKey: String?, plan: CodeGenerationPlan, progressTracker: ProgressTracker) async throws {
        // Setup progresTracker
        await MainActor.run {
            progressTracker.startEstimation(totalTasks: plan.planFC.steps.compactMap({$0.action == .edit}).count)
        }
        
        // Generate and refactor
        try await generateAndRefactor(
            authToken: authToken,
            openAIKey: openAIKey,
            model: plan.model,
            systemMessage: plan.editActionSystemMessage,
            instructions: plan.instructions,
            copyCurrentFilesToTempFiles: plan.copyCurrentFilesToTempFiles,
            planFC: plan.planFC,
            progressTracker: progressTracker)
    }
    
    func generateAndRefactor(authToken: String, openAIKey: String?, model: GPTModels, systemMessage: String, instructions: String, copyCurrentFilesToTempFiles: Bool, planFC: PlanCodeGenerationFC, progressTracker: ProgressTracker) async throws {
        for step in planFC.steps {
            do {
                try await executeStep(
                    authToken: authToken,
                    openAIKey: openAIKey,
                    model: model,
                    systemMessage: systemMessage,
                    instructions: instructions,
                    copyCurrentFileToTempFile: copyCurrentFilesToTempFiles,
                    step: step)
            } catch {
                print("Error executing step in CodeGenerationPlanExecutor, continuing... \(error)")
            }
            
            await MainActor.run {
                progressTracker.completeTask()
            }
        }
    }
    
    func executeStep(authToken: String, openAIKey: String?, model: GPTModels, systemMessage: String, instructions: String, copyCurrentFileToTempFile: Bool, step: PlanCodeGenerationFC.Step) async throws {
        switch step.action {
        case .edit:
            // Perform edit and add to previousEditResponses
            try await performEdit(
                authToken: authToken,
                openAIKey: openAIKey,
                model: model,
                systemMessage: systemMessage,
                instructions: instructions,
                editPrompt: step.editInstructions,
                editFilepath: step.filepath,
                referenceFilepaths: step.referenceFilepaths,
                copyCurrentFileToTempFile: copyCurrentFileToTempFile)
        case .create:
            performCreate(filepath: step.filepath)
        case .delete:
            try performDelete(filepath: step.filepath)
        }
    }
    
    func performCreate(filepath: String) {
        // Create file if there is an extension, otherwise create a folder
        let fileManager = FileManager.default
        let pathExtension = (filepath as NSString).pathExtension
        
        if pathExtension.isEmpty {
            // No extension present, create a folder
            do {
                try fileManager.createDirectory(atPath: filepath, withIntermediateDirectories: true, attributes: nil)
                print("Folder created at \(filepath)")
            } catch {
                print("Error creating folder at \(filepath): \(error)")
            }
        } else {
            // Extension is present, create a file
            let created = fileManager.createFile(atPath: filepath, contents: nil, attributes: nil)
            if created {
                print("File created at \(filepath)")
            } else {
                print("Error creating file at \(filepath)")
            }
        }
    }
    
    func performDelete(filepath: String) throws {
        try FileManager.default.trashItem(at: URL(fileURLWithPath: filepath), resultingItemURL: nil)
    }
    
    func performEdit(authToken: String, openAIKey: String?, model: GPTModels, systemMessage: String, instructions: String, editPrompt: String?, editFilepath: String, referenceFilepaths: [String]?, copyCurrentFileToTempFile: Bool) async throws {
        // Build context by getting text from referenceFilepaths joined as the first and only string as user message and from previousEditMessages as assistant messages
        var context: [(message: String, role: CompletionRole)] = []
        if let referenceFilepaths = referenceFilepaths {
            context.append(("FILES FOR REFERENCE: " + referenceFilepaths.compactMap({FilePrettyPrinter.getFileContent(filepath: $0)}).joined(separator: "\n"), .user))
        }
        context.append(contentsOf: previousEditResponses.map({($0, .assistant)}))
        
        // Build additionalInput from instructions and editPrompt
        let additionalInput: String = instructions + (editPrompt == nil || editPrompt!.isEmpty ? "" : " \(editPrompt!)")
        
        // Refactor file and add its response to previousEditResponses
        let editResponse = try await EditFileCodeGenerator.refactorFile(
            authToken: authToken,
            openAIKey: openAIKey,
            model: model,
            additionalInput: additionalInput,
            filepath: editFilepath,
            systemMessage: systemMessage,
            context: context,
            copyCurrentFileToTempFile: copyCurrentFileToTempFile)
        if let editResponse = editResponse {
            previousEditResponses.append(editResponse)
        }
    }
    
}

