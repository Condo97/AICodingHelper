//
//  CodeGenerationPlan.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/6/24.
//

import Foundation


struct CodeGenerationPlan {
    
    let model: GPTModels
    let instructions: String // The action aiPrompt and userInput
    let copyCurrentFilesToTempFiles: Bool
    let planFC: PlanCodeGenerationFC
    
}
