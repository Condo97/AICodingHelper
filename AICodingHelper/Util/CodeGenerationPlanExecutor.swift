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
            rootFilepath: plan.rootFilepath,
            copyCurrentFilesToTempFiles: plan.copyCurrentFilesToTempFiles,
            planFC: plan.planFC,
            progressTracker: progressTracker)
    }
    
    func generateAndRefactor(authToken: String, openAIKey: String?, model: GPTModels, systemMessage: String, instructions: String, rootFilepath: String, copyCurrentFilesToTempFiles: Bool, planFC: PlanCodeGenerationFC, progressTracker: ProgressTracker) async throws {
        for step in planFC.steps {
            do {
                try await executeStep(
                    authToken: authToken,
                    openAIKey: openAIKey,
                    model: model,
                    systemMessage: systemMessage,
                    instructions: instructions,
                    rootFilepath: rootFilepath,
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
    
    func executeStep(authToken: String, openAIKey: String?, model: GPTModels, systemMessage: String, instructions: String, rootFilepath: String, copyCurrentFileToTempFile: Bool, step: PlanCodeGenerationFC.Step) async throws {
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
                rootFilepath: rootFilepath,
                editFilepath: step.filepath,
                referenceFilepaths: step.referenceFilepaths,
                copyCurrentFileToTempFile: copyCurrentFileToTempFile)
        case .create:
            performCreate(filepath: step.filepath, rootFilepath: rootFilepath)
        case .delete:
            try performDelete(filepath: step.filepath, rootFilepath: rootFilepath)
        }
    }
    
    func performCreate(filepath: String, rootFilepath: String) {
        // Create file if there is an extension, otherwise create a folder
        let fileManager = FileManager.default
        let pathExtension = (filepath as NSString).pathExtension
        
        let fullFilepath = rootFilepath + (filepath.hasPrefix("/") ? "" : "/") + filepath
        let directoryPath = (fullFilepath as NSString).deletingLastPathComponent
        
        do {
            // Create directories if they don't exist
            try fileManager.createDirectory(atPath: directoryPath, withIntermediateDirectories: true, attributes: nil)
            
            if pathExtension.isEmpty {
                // No extension present, create a folder
                try fileManager.createDirectory(atPath: fullFilepath, withIntermediateDirectories: true, attributes: nil)
                print("Folder created at \(fullFilepath)")
            } else {
                // Extension is present, create a file
                let created = fileManager.createFile(atPath: fullFilepath, contents: nil, attributes: nil)
                if created {
                    print("File created at \(fullFilepath)")
                } else {
                    print("Error creating file at \(fullFilepath)")
                }
            }
        } catch {
            print("Error creating directories or file at \(fullFilepath): \(error)")
        }
    }
    
    func performDelete(filepath: String, rootFilepath: String) throws {
        let fullFilepath = rootFilepath + (filepath.hasPrefix("/") ? "" : "/") + filepath
        try FileManager.default.trashItem(at: URL(fileURLWithPath: fullFilepath), resultingItemURL: nil)
    }
    
    func performEdit(authToken: String, openAIKey: String?, model: GPTModels, systemMessage: String, instructions: String, editPrompt: String?, rootFilepath: String, editFilepath: String, referenceFilepaths: [String]?, copyCurrentFileToTempFile: Bool) async throws {
        // Build context by getting text from referenceFilepaths joined as the first and only string as user message and from previousEditMessages as assistant messages
        var context: [(message: String, role: CompletionRole)] = []
        if let referenceFilepaths = referenceFilepaths {
            context.append(("FILES FOR REFERENCE: " + referenceFilepaths.compactMap({FilePrettyPrinter.getFileContent(relativeFilepath: $0, rootFilepath: rootFilepath)}).joined(separator: "\n"), .user))
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
            filepath: rootFilepath + (editFilepath.hasPrefix("/") ? "" : "/") + editFilepath,
            systemMessage: systemMessage,
            context: context,
            copyCurrentFileToTempFile: copyCurrentFileToTempFile)
        if let editResponse = editResponse {
            previousEditResponses.append(editResponse)
        }
    }
    
}

