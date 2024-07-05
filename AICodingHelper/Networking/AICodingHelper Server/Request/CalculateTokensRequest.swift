//
//  CalculateTokensRequest.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/4/24.
//

import Foundation


struct CalculateTokensRequest: Codable {
    
    var authToken: String
    var model: GPTModels
    var input: String
    
    enum CodingKeys: String, CodingKey {
        case authToken
        case model
        case input
    }
    
}
