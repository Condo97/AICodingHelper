//
//  IsActiveResponse.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/15/24.
//

import Foundation


struct IsActiveResponse: Codable {
    
    struct Body: Codable {
        
        var isActive: Bool
        var subscription: Subscriptions
        
        enum CodingKeys: String, CodingKey {
            case isActive
            case subscription
        }
        
    }
    
    var body: Body
    var success: Int
    
    enum CodingKeys: String, CodingKey {
        case body = "Body"
        case success = "Success"
    }
    
}
