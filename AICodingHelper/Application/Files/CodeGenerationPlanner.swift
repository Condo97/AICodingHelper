//
//  CodeGenerationPlanner.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/6/24.
//

import Foundation


class CodeGenerationPlanner {
    
    // Creates CodeGenerationPlan
    
    static func makePlan(authToken: String, model: GPTModels, instructions: String, selectedFilepaths: [String], copyCurrentFilesToTempFiles: Bool) async throws -> CodeGenerationPlan? {
        // Ensure unwrap PlanCodeGenerationFC from CodeGenerationPlanGenerator
        guard let planCodeGeneratorFC = try await CodeGenerationPlanGenerator.generatePlan(
            authToken: authToken,
            model: model,
            instructions: instructions,
            selectedFilepaths: selectedFilepaths) else {
            // TODO: Handle Errors
            return nil
        }
        
        // Return CodeGenerationPlan
        return CodeGenerationPlan(
            model: model,
            instructions: instructions,
            copyCurrentFilesToTempFiles: copyCurrentFilesToTempFiles,
            planFC: planCodeGeneratorFC)
    }
    
}
