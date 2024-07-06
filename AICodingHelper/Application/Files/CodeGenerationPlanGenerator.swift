//
//  CodeGenerationPlanGenerator.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/6/24.
//

import Foundation


class CodeGenerationPlanGenerator {
    
    // Creates PlanCodeGenerationFC
    
    private static let systemMessage = "Create a plan for generating code."
    private static let additionalInstructionMessage = "Use the provided context and code to create a plan for generating code with the following instructions."
    
    static func generatePlan(authToken: String, model: GPTModels, instructions: String, selectedFilepaths: [String]) async throws -> PlanCodeGenerationFC? {
        // Well this should be creating a list of tasks with CodeGenerationTask or something, right? So it should be before accepting codeGenerationTask. Also this one should not be added to the user's token count and stuff
        
        // Create input from additionalInstructionsMessage + instructions + selectedFilepaths
        let input = additionalInstructionMessage + "\n" + instructions + "\n\n" + selectedFilepaths.compactMap({FilePrettyPrinter.getFileContent(filepath: $0)}).joined(separator: "\n")
        
        return try await planCodeGeneration(
            authToken: authToken,
            model: model,
            input: input,
            systemMessage: systemMessage)
    }
    
    static func planCodeGeneration(authToken: String, model: GPTModels, input: String, systemMessage: String) async throws -> PlanCodeGenerationFC? {
        // Create PlanCodeGenerationRequest
        let planCodeGenerationRequest = FunctionCallRequest(
            authToken: authToken,
            model: model,
            systemMessage: systemMessage,
            input: input)
        
        // Get from AICodingHelperHTTPSConnector
        let planCodeGenerationResponse = try await AICodingHelperHTTPSConnector.planCodeGeneration(request: planCodeGenerationRequest)
        
        // Ensure unwrap first tool call data
        guard let firstToolCall = planCodeGenerationResponse.body.response.choices[safe: 0]?.message.toolCalls[safe: 0]?.function,
              let firstToolCallData = firstToolCall.arguments.data(using: .utf8) else {
            // TODO: Handle Errors, this should probably be throwing something idk I need to be throwing things more lol
            return nil
        }
        
        // Parse PlanCodeGenerationFC & return
        return try JSONDecoder().decode(PlanCodeGenerationFC.self, from: firstToolCallData)
    }
    
}

