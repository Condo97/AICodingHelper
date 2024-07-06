//
//  PlanCodeGenerationFC.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/6/24.
//

import Foundation


struct PlanCodeGenerationFC: Codable {
    
    struct Step: Codable {
        
        enum ActionType: String, Codable {
            case edit
            case create
            case delete
        }
        
        let index: Int
        let action: ActionType
        let filepath: String
        let editSummary: String?
        let editReferenceFilepaths: [String]?
        
        enum CodingKeys: String, CodingKey {
            case index
            case action
            case filepath
            case editSummary = "edit_summary"
            case editReferenceFilepaths = "edit_reference_filepaths"
        }
        
    }
    
    let steps: [Step]
    
    enum CodingKeys: String, CodingKey {
        case steps
    }
    
}
