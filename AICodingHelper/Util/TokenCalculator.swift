//
//  TokenCalculator.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/4/24.
//

import Foundation


class TokenCalculator {
    
    static func getEstimatedTokens(authToken: String, codeGenerationPlan: CodeGenerationPlan) async -> Int {
        var estimatedTokens: Int = 0
        
        await withTaskGroup(of: Int.self) { taskGroup in
            for step in codeGenerationPlan.planFC.steps {
                switch step.action {
                case .edit:
                    taskGroup.addTask {
                        // Get string from all files in editReferenceFilepaths
                        if let additionalInput = step.referenceFilepaths?.compactMap({FilePrettyPrinter.getFileContent(filepath: $0)}).joined(separator: "\n") {
                            do {
                                // Return estimated tokens to taskGroup
                                return try await getEstimatedTokens(
                                    authToken: authToken,
                                    filepath: step.filepath,
                                    additionalInput: additionalInput)
                            } catch {
                                // TODO: Handle Errors
                                print("Error getting estimated tokens for \(step.filepath) in TokenCalculator... \(error)")
                            }
                        }
                        
                        return 0
                    }
                case .create:
                    // No tokens used
                    break
                case .delete:
                    // No tokens used
                    break
                }
            }
            
            for await tokens in taskGroup {
                // Add tokens to estimatedTokens
                estimatedTokens += tokens
            }
        }
        
        return estimatedTokens
    }

    static func getEstimatedTokens(authToken: String, filepath: String, additionalInput: String) async throws -> Int {
        var pathTokens = 0
        let fileManager = FileManager.default
        var isDirectory: ObjCBool = false
        
        if fileManager.fileExists(atPath: filepath, isDirectory: &isDirectory), isDirectory.boolValue {
            do {
                let contents = try fileManager.contentsOfDirectory(atPath: filepath)
                for content in contents {
                    let contentPath = (filepath as NSString).appendingPathComponent(content)
                    pathTokens += try await getEstimatedTokens(authToken: authToken, filepath: contentPath, additionalInput: additionalInput)
                }
            } catch {
                print("Error reading directory \(filepath) in TokenCalculator... \(error)")
            }
        } else {
            do {
                let fileData = try Data(contentsOf: URL(fileURLWithPath: filepath))
                if let fileText = String(data: fileData, encoding: .utf8) {
                    let tokens = try await calculateTokens(authToken: authToken, inputs: [fileText, additionalInput])
                    pathTokens += tokens
                }
            } catch {
                print("Error reading file \(filepath) in TokenCalculator... \(error)")
            }
        }
        
        return pathTokens
    }
    
    static func calculateTokens(authToken: String, inputs: [String]) async throws -> Int {
        // Calculate tokens for inputs separated by new line
        let calculateTokensRequest = CalculateTokensRequest(
            authToken: authToken,
            model: .GPT4o,
            input: inputs.joined(separator: "\n"))
        
        let calculateTokensResponse = try await AICodingHelperHTTPSConnector.calculateTokens(request: calculateTokensRequest)
        
        return calculateTokensResponse.body.tokens
    }
    
}
