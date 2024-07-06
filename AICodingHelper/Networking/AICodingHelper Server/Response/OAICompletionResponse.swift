//
//  OAICompletionResponse.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/6/24.
//

import Foundation


struct OAICompletionResponse: Codable {
    
    struct Body: Codable {
        
        let response: OAIChatCompletionResponse
        
        enum CodingKeys: String, CodingKey {
            case response
        }
        
    }
    
    let body: Body
    let success: Int
    
    enum CodingKeys: String, CodingKey {
        case body = "Body"
        case success = "Success"
    }
    
}
