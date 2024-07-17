//
//  PlanCodeGenerationFC.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/6/24.
//

import Foundation


struct PlanCodeGenerationFC: Codable {
    
    struct Step: Codable, Identifiable {
        
        enum ActionType: String, Codable {
            case edit
            case create
            case delete
        }
        
        let id = UUID()
        var index: Int
        var action: ActionType
        var filepath: String
        var editInstructions: String?
        var referenceFilepaths: [String]?
        
        enum CodingKeys: String, CodingKey {
            case index
            case action
            case filepath
            case editInstructions = "edit_instructions"
            case referenceFilepaths = "reference_filepaths"
        }
        
    }
    
    var steps: [Step]
    
    enum CodingKeys: String, CodingKey {
        case steps
    }
    
}
