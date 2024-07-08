//
//  PlannedCodeGenerationRefactorService.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/6/24.
//

import Foundation


class CodeGenerationPlanExecutor {

    static func generateAndRefactor(authToken: String, plan: CodeGenerationPlan) async throws {
        try await generateAndRefactor(
            authToken: authToken,
            model: plan.model,
            systemMessage: plan.editActionSystemMessage,
            instructions: plan.instructions,
            copyCurrentFilesToTempFiles: plan.copyCurrentFilesToTempFiles,
            planFC: plan.planFC)
    }
    
    static func generateAndRefactor(authToken: String, model: GPTModels, systemMessage: String, instructions: String, copyCurrentFilesToTempFiles: Bool, planFC: PlanCodeGenerationFC) async throws {
        for step in planFC.steps {
            do {
                try await executeStep(
                    authToken: authToken,
                    model: model,
                    systemMessage: systemMessage,
                    instructions: instructions,
                    copyCurrentFileToTempFile: copyCurrentFilesToTempFiles,
                    step: step)
            } catch {
                print("Error executing step in CodeGenerationPlanExecutor, continuing... \(error)")
            }
        }
    }
    
    static func executeStep(authToken: String, model: GPTModels, systemMessage: String, instructions: String, copyCurrentFileToTempFile: Bool, step: PlanCodeGenerationFC.Step) async throws {
        switch step.action {
        case .edit:
            try await performEdit(
                authToken: authToken,
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
    
    static func performCreate(filepath: String) {
        FileManager.default.createFile(atPath: filepath, contents: nil)
    }
    
    static func performDelete(filepath: String) throws {
        try FileManager.default.trashItem(at: URL(fileURLWithPath: filepath), resultingItemURL: nil)
    }
    
    static func performEdit(authToken: String, model: GPTModels, systemMessage: String, instructions: String, editPrompt: String?, editFilepath: String, referenceFilepaths: [String]?, copyCurrentFileToTempFile: Bool) async throws {
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
            systemMessage: systemMessage,
            context: context,
            copyCurrentFileToTempFile: copyCurrentFileToTempFile)
    }
    
}

