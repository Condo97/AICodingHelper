//
//  FilepathCodeGenerationPrompt.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/5/24.
//

import Foundation


struct FilepathCodeGenerationPrompt {
        
    var model: GPTModels
//    var action: ActionType
    var additionalInput: String
    var systemMessage: String
    var context: [(message: String, role: CompletionRole)]
    var filepath: String
//    var additionalContextFilepaths: [String]?
//    var options: GenerateOptions
    
}


extension FilepathCodeGenerationPrompt {
    
    static func from(model: GPTModels, action: ActionType, userInput: String?, filepaths: [String], alternateContextFilepaths: [String]?) -> [FilepathCodeGenerationPrompt] {
        // Create contextString from all alternateContextFilepaths or if nil all of the filepaths
        let contextString = {
            if let alternateContextFilepaths = alternateContextFilepaths {
                return alternateContextFilepaths.map({FilePrettyPrinter.getFileContent(filepath: $0)}).joined(separator: "\n")
            } else {
                return filepaths.map({FilePrettyPrinter.getFileContent(filepath: $0)}).joined(separator: "\n")
            }
        }()
        
        // Get filepathCodeGenerationPrompts
        var filepathCodeGenerationPrompts: [FilepathCodeGenerationPrompt] = []
        
        for filepath in filepaths {
            filepathCodeGenerationPrompts.append(contentsOf: from(model: model, action: action, userInput: userInput, filepath: filepath, contextString: contextString))
        }
        
        return filepathCodeGenerationPrompts
    }
    
    static func from(model: GPTModels, action: ActionType, userInput: String?, filepath: String, contextString: String) -> [FilepathCodeGenerationPrompt] {
        var filepathCodeGenerationPrompts: [FilepathCodeGenerationPrompt] = []
        
        // If the filepath points to a directory call again with each subfile adding to filepathCodeGenerationPrompts, otherwise addf ile contents to filepathCodeGenerationPrompts
        var isDirectory: ObjCBool = false
        if FileManager.default.fileExists(atPath: filepath, isDirectory: &isDirectory) {
            if isDirectory.boolValue {
                do {
                    let subfiles = try FileManager.default.contentsOfDirectory(atPath: filepath)
                    for subfile in subfiles {
                        let subfilePath = (filepath as NSString).appendingPathComponent(subfile)
                        
                        filepathCodeGenerationPrompts.append(contentsOf: from(
                            model: model,
                            action: action,
                            userInput: userInput,
                            filepath: subfilePath,
                            contextString: contextString))
                        
                    }
                } catch {
                    // TODO: Handle Errors
                    print("Error getting subfiles from directory in WideScopeChatGenerator... \(error)")
                }
            } else {
                /* Should look something like
                 System
                    You are an AI coding helper service in an IDE so you must format all your responses in code that would be valid in an IDE.
                 User Message 1
                    <Context Filepaths File Strings>
        //            You are an AI coding helper in an IDE so all responses must be in code that would be valid in an IDE.
        //            -- if using alternative context files, which would be something like the project files
        //                Here are other files in my project to reference
        //                <Project Files>
        //            -- if not using alternative context files and therefore just using selection as context
        //                Here are other files included in the selection to eventually be refactored, for reference purposes.
        //                <Selected Files>
                 User Message 2
                    You are an AI coding helper in an IDE so all responses must be in code that would be valid in an IDE.
                    <Action AI Prompt>
                    <Additional Input>
                    <Code>
                 */
                
                // Parse and assemble systemMessage and parse and add context String from alternativeContextFiles or if nil files
                let systemMessage = "You are an AI coding helper service in an IDE so you must format all your responses in code that would be valid in an IDE. Do not include ```LanguageName or ``` to denote code. You only respond with code that is valid in that language. You only respond to the one requested file. All files will be provided in turn, so therefore you will respond to each individually to preserve correct formatting to the IDE since it is looking to receive one file. You may include messages in comments if the langauge supports comments."
                let contextFilepathsMessageString: (message: String, role: CompletionRole) = {
                    let userMessage1_1 = "You are an AI coding helper in an IDE so all responses must be in code that would be valid in an IDE."
                    let userMessage1_2 = "Here are other files in my project to reference"
                    return ([userMessage1_1, userMessage1_2, contextString].joined(separator: "\n"), .user)
                }()
                
                // Create additionalInput from action and userInput
                let additionalInput = action.aiPrompt + (userInput == nil ? "" : ("\n" + userInput!))
                
                // Add FilpeathCodeGenerationPrompt to filepathCodeGenerationPrompts
                filepathCodeGenerationPrompts.append(
                    FilepathCodeGenerationPrompt(
                        model: model,
                        additionalInput: additionalInput,
                        systemMessage: systemMessage,
                        context: [contextFilepathsMessageString],
                        filepath: filepath)
                )
            }
        }
        
        // Return filepathCodeGenerationPrompts
        return filepathCodeGenerationPrompts
    }
    
//    static func from(model: GPTModels, action: ActionType, additionalInput: String?, systemMessage: String, context: [String], filepath: String, contextFilepaths: [String]) -> FilepathCodeGenerationPrompt {
//        
//        // TODO: Use entire project as context option add to context
//        
//        // Return
//        return FilepathCodeGenerationPrompt(
//            model: model,
//            additionalInput: additionalInput,
//            systemMessage: systemMessage,
//            context: [userMessage1],
//            filepaths: filepaths)
//    }
    
}
