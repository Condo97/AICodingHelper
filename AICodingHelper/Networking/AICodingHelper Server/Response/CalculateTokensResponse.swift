//
//  CalculateTokensResponse.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/4/24.
//

import Foundation


struct CalculateTokensResponse: Codable {
    
    struct Body: Codable {
        
        var tokens: Int
        
        enum CodingKeys: String, CodingKey {
            case tokens
        }
        
    }
    
    var body: Body
    var success: Int
    
    enum CodingKeys: String, CodingKey {
        case body = "Body"
        case success = "Success"
    }
    
}
