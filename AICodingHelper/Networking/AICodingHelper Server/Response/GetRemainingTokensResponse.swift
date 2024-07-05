//
//  GetRemainingTokensResponse.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/30/23.
//

import Foundation

struct GetRemainingTokensResponse: Codable {
    
    struct Body: Codable {
        
        var remainingTokens: Int
        
        enum CodingKeys: String, CodingKey {
            case remainingTokens
        }
        
    }
    
    var body: Body
    var success: Int
    
    enum CodingKeys: String, CodingKey {
        case body = "Body"
        case success = "Success"
    }
    
}
