//
//  CodeGenerationPlan.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/6/24.
//

import Foundation


struct CodeGenerationPlan {
    
    var model: GPTModels
    var rootFilepath: String
    var editActionSystemMessage: String
    var instructions: String // The action aiPrompt and userInput
    var copyCurrentFilesToTempFiles: Bool
    var planFC: PlanCodeGenerationFC
    
}
