//
//  TokenCalculator.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/4/24.
//

import Foundation


class TokenCalculator {
    
    static func getEstimatedTokens(authToken: String, wideScopeChatGenerationTask: WideScopeChatGenerator.WideScopeChatGenerationTask) async -> Int {
        var estimatedTokens: Int = 0
        
        await withTaskGroup(of: Int.self) { taskGroup in
            for filepathCodeGenerationPrompt in wideScopeChatGenerationTask.filepathCodeGenerationPrompts {
                taskGroup.addTask {
                    do {
                        // Return estimated tokens to taskGroup
                        return try await getEstimatedTokens(
                            authToken: authToken,
                            filepath: filepathCodeGenerationPrompt.filepath,
                            additionalInput: (filepathCodeGenerationPrompt.context + [filepathCodeGenerationPrompt.systemMessage, filepathCodeGenerationPrompt.additionalInput]).joined(separator: "\n"))
                    } catch {
                        print("Error getting estimated tokens for \(filepathCodeGenerationPrompt.filepath)... \(error)")
                        return 0
                    }
                }
            }
            
            for await tokens in taskGroup {
                // Add tokens to estimatedTokens
                estimatedTokens += tokens
            }
        }
        
        return estimatedTokens
    }
    
//    static func getEstimatedTokens(authToken: String, filepathCodeGenerationPrompt: FilepathCodeGenerationPrompt) async -> Int {
//        await getEstimatedTokens(
//            authToken: authToken,
//            filepaths: filepathCodeGenerationPrompt.filepaths,
//            contextForEachFile: ([filepathCodeGenerationPrompt.systemMessage, filepathCodeGenerationPrompt.additionalInput] + filepathCodeGenerationPrompt.context).joined(separator: "\n"))
//    }
    
//    static func getEstimatedTokens(authToken: String, filepaths: [String], contextForEachFile: String) async -> Int {
//        var totalTokens = 0
//        
//        for filepath in filepaths {
//            do {
//                totalTokens += try await getEstimatedTokens(authToken: authToken, filepath: filepath, contextForEachFile: contextForEachFile)
//            } catch {
//                print("Error processing \(filepath) in TokenCalculator... \(error)")
//            }
//        }
//        
//        return totalTokens
//    }

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
