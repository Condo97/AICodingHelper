//
//  GetChatResponse.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 6/28/24.
//

import Foundation

struct GetChatResponse: Codable {
    
    struct Body: Codable {
        
        let oaiResponse: ChatCompletionChunk
        
        enum CodingKeys: String, CodingKey {
            case oaiResponse
        }
        
    }
    
    let body: Body
    let success: Int
    
    enum CodingKeys: String, CodingKey {
        case body = "Body"
        case success = "Success"
    }
    
}
