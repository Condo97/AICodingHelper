//
//  ValidateOpenAIKeyResponse.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/17/24.
//

import Foundation


struct ValidateOpenAIKeyResponse: Codable {
    
    struct Body: Codable {
        
        var valid: Bool
        
        enum CodingKeys: String, CodingKey {
            case valid
        }
        
    }
    
    var body: Body
    var success: Int
    
    enum CodingKeys: String, CodingKey {
        case body = "Body"
        case success = "Success"
    }
    
}
