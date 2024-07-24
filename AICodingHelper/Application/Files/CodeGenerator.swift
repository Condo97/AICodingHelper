//
//  CodeGenerator.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/19/24.
//

import Foundation


class CodeGenerator {
    
    var isValid: Bool {
        aiCodingHelperHTTPSConnector.isValid
    }
    
    private static let systemMessage = "LONG OUTPUT CAPABLE, make sure to output all files and modifications necessary. - You are an AI coder bot. You are provided with existing files as context. Create files with content to provide implementation. Be strategic. You may create as many files as required. You can create them as filename.extension and you can include it in a directory as well. If a file exists for the filepath, it will be replaced with the file you provide."
    private static let additionalInstructionMessage = "";
    
    private let aiCodingHelperHTTPSConnector: AICodingHelperHTTPSConnector = AICodingHelperHTTPSConnector()
    
    func generateCode(authToken: String, openAIKey: String?, model: GPTModels, instructions: String, rootFilepath: String, selectedFilepaths: [String], copyCurrentFilesToTempFiles: Bool) async throws -> GenerateCodeFC? {
        // Remove baseFilepath from selectedFilepaths TODO: Should this be done here?
        let relativeSelectedFilepaths: [String] = selectedFilepaths.map({$0.replacingOccurrences(of: rootFilepath, with: "")})
        
        // Create input from additionalInstructionsMessage + instructions + selectedFilepaths
        let input = CodeGenerator.additionalInstructionMessage + "\n" + instructions + "\n\nBEGIN REFERENCE FILES:\n" + relativeSelectedFilepaths.compactMap({FilePrettyPrinter.getFileContent(relativeFilepath: $0, rootFilepath: rootFilepath)}).joined(separator: "\n")
        
        // Create messages from systemMessage and input
        let messages: [OAIChatCompletionRequestMessage] = [
            OAIChatCompletionRequestMessage(
                role: .system,
                content: [
                    .text(OAIChatCompletionRequestMessageContentText(text: CodeGenerator.systemMessage))
                ]),
            OAIChatCompletionRequestMessage(
                role: .user,
                content: [
                    .text(OAIChatCompletionRequestMessageContentText(text: input))
                ])
        ]
        
        // Create request
        let request = FunctionCallRequest(
            authToken: authToken,
            openAIKey: openAIKey,
            model: model,
            messages: messages)
        
        // Get response
        let response = try await aiCodingHelperHTTPSConnector.functionCallRequest(
            endpoint: Constants.Networking.HTTPS.Endpoints.generateCode,
            request: request)
        
        // Ensure unwrap first tool call data
        guard let firstToolCall = response.body.response.choices[safe: 0]?.message.toolCalls[safe: 0]?.function,
              let firstToolCallData = firstToolCall.arguments.data(using: .utf8) else {
            // TODO: Handle Errors, this should probably be throwing something idk I need to be throwing things more lol
            return nil
        }
        
        // Parse GenerateCodeFC and return
        let generateCodeFC = try JSONDecoder().decode(GenerateCodeFC.self, from: firstToolCallData)
        
        return generateCodeFC
        
//        // Save files with content for each file in generateCodeFC TODO: CopyCurrentFilesToTempFiles implementation
//        for file in generateCodeFC.files {
//            createFile(
//                filepath: rootFilepath + (file.filepath.hasPrefix("/") ? "" : "/") + file.filepath,
//                content: file.content)
//        }
    }
    
}
