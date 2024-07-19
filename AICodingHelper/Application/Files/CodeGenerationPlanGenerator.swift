//
//  CodeGenerationPlanGenerator.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/6/24.
//

import Foundation


class CodeGenerationPlanGenerator {
    
    // Creates PlanCodeGenerationFC
    
    private static let systemMessage = "Create a detailed plan to prompt GPT in a series of steps to complete the task in the prompt. You may edit, create, delete files. Please make sure to include as many files as necessary for each step in the plan as they are the only files available for GPT to reference. You must include an index, action, and filepath. If making edits include reference_filepaths if any and edit_instructions with instructions to make the edits. Available Actions, choose thoughtfully: CREATE - makes a new blank file, no GPT action performed. DELETE - deletes file from system. EDIT - rewrites entire file with GPT response."
    private static let additionalInstructionMessage = "Create a detailed plan to prompt GPT in a series of steps to complete the task in the prompt. Avaliable Actions: CREATE - makes a new blank file, no GPT action performed. DELETE - deletes file from system. EDIT - rewrites entire file with GPT response."
    
    static func generatePlan(authToken: String, openAIKey: String?, model: GPTModels, instructions: String, rootFilepath: String, selectedFilepaths: [String]) async throws -> PlanCodeGenerationFC? {
        // Well this should be creating a list of tasks with CodeGenerationTask or something, right? So it should be before accepting codeGenerationTask. Also this one should not be added to the user's token count and stuff
        
        // Create input from additionalInstructionsMessage + instructions + selectedFilepaths
        let input = additionalInstructionMessage + "\n" + instructions + "\n\n" + selectedFilepaths.compactMap({FilePrettyPrinter.getFileContent(relativeFilepath: $0, rootFilepath: rootFilepath)}).joined(separator: "\n")
        
        return try await planCodeGeneration(
            authToken: authToken,
            openAIKey: openAIKey,
            model: model,
            input: input,
            systemMessage: systemMessage)
    }
    
    static func planCodeGeneration(authToken: String, openAIKey: String?, model: GPTModels, input: String, systemMessage: String) async throws -> PlanCodeGenerationFC? {
        // Create PlanCodeGenerationRequest
        let planCodeGenerationRequest = FunctionCallRequest(
            authToken: authToken,
            openAIKey: openAIKey,
            model: model,
            systemMessage: systemMessage,
            input: input)
        
        // Get from AICodingHelperHTTPSConnector
        let planCodeGenerationResponse = try await AICodingHelperHTTPSConnector.functionCallRequest(endpoint: Constants.Networking.HTTPS.Endpoints.planCodeGeneration, request: planCodeGenerationRequest)
        
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

