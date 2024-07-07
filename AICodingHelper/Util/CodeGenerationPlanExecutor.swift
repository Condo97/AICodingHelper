//
//  PlannedCodeGenerationRefactorService.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/6/24.
//

import Foundation


class CodeGenerationPlanExecutor {
    
    private static let editSystemMessage = "PLEASE NOTE YOU ARE PERFORMING AN EDIT TASK FOR ONLY THE GIVEN FILE. You may not add other files to it, you will be asked to generate those other files at a later point. You are an AI coding helper service in an IDE so you must format all your responses in code that would be valid in an IDE. Do not include ```LanguageName or ``` to denote code. You only respond with code that is valid in that language. You only respond to the one requested file. All files will be provided in turn, so therefore you will respond to each individually to preserve correct formatting to the IDE since it is looking to receive one file."

    static func generateAndRefactor(authToken: String, plan: CodeGenerationPlan) async throws {
        try await generateAndRefactor(
            authToken: authToken,
            model: plan.model,
            instructions: plan.instructions,
            copyCurrentFilesToTempFiles: plan.copyCurrentFilesToTempFiles,
            planFC: plan.planFC)
    }
    
    static func generateAndRefactor(authToken: String, model: GPTModels, instructions: String, copyCurrentFilesToTempFiles: Bool, planFC: PlanCodeGenerationFC) async throws {
        for step in planFC.steps {
            do {
                try await executeStep(
                    authToken: authToken,
                    model: model,
                    instructions: instructions,
                    copyCurrentFileToTempFile: copyCurrentFilesToTempFiles,
                    step: step)
            } catch {
                print("Error executing step in CodeGenerationPlanExecutor, continuing... \(error)")
            }
        }
    }
    
    static func executeStep(authToken: String, model: GPTModels, instructions: String, copyCurrentFileToTempFile: Bool, step: PlanCodeGenerationFC.Step) async throws {
        switch step.action {
        case .edit:
            try await performEdit(
                authToken: authToken,
                model: model,
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
    
    static func performCreate(filepath: String) {
        FileManager.default.createFile(atPath: filepath, contents: nil)
    }
    
    static func performDelete(filepath: String) throws {
        try FileManager.default.trashItem(at: URL(fileURLWithPath: filepath), resultingItemURL: nil)
    }
    
    static func performEdit(authToken: String, model: GPTModels, instructions: String, editPrompt: String?, editFilepath: String, referenceFilepaths: [String]?, copyCurrentFileToTempFile: Bool) async throws {
        // Build context by getting text from referenceFilepaths joined as the first and only string
        var context: [String] = []
        if let referenceFilepaths = referenceFilepaths {
            context.append("FILES FOR REFERENCE: " + referenceFilepaths.compactMap({FilePrettyPrinter.getFileContent(filepath: $0)}).joined(separator: "\n"))
        }
        
        // Build additionalInput from instructions and editPrompt
        let additionalInput: String = instructions + (editPrompt == nil || editPrompt!.isEmpty ? "" : " \(editPrompt!)")
        
        // Refactor file
        try await EditFileCodeGenerator.refactorFile(
            authToken: authToken,
            model: model,
            additionalInput: additionalInput,
            filepath: editFilepath,
            systemMessage: editSystemMessage,
            context: context,
            copyCurrentFileToTempFile: copyCurrentFileToTempFile)
    }
    
}

