//
//  CodeGenerationPlanner.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/6/24.
//

import Foundation


class CodeGenerationPlanner {
    
    // Creates CodeGenerationPlan
    
    static func makePlan(authToken: String, openAIKey: String?, model: GPTModels, editActionSystemMessage: String, instructions: String, rootFilepath: String, selectedFilepaths: [String], copyCurrentFilesToTempFiles: Bool) async throws -> CodeGenerationPlan? {
        // Remove baseFilepath from selectedFilepaths TODO: Should this be done here?
        let relativeSelectedFilepaths: [String] = selectedFilepaths.map({$0.replacingOccurrences(of: rootFilepath, with: "")})
        
        // Ensure unwrap PlanCodeGenerationFC from CodeGenerationPlanGenerator
        guard let planCodeGeneratorFC = try await CodeGenerationPlanGenerator().generatePlan(
            authToken: authToken,
            openAIKey: openAIKey,
            model: model,
            instructions: instructions,
            rootFilepath: rootFilepath,
            selectedFilepaths: relativeSelectedFilepaths) else {    
            // TODO: Handle Errors
            return nil
        }
        
        // Return CodeGenerationPlan
        return CodeGenerationPlan(
            model: model,
            rootFilepath: rootFilepath,
            editActionSystemMessage: editActionSystemMessage,
            instructions: instructions,
            copyCurrentFilesToTempFiles: copyCurrentFilesToTempFiles,
            planFC: planCodeGeneratorFC)
    }
    
}
