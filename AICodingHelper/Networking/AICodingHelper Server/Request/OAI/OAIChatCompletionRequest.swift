//
//  OAIChatCompletionRequest.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 6/28/24.
//

import Foundation


struct OAIChatCompletionRequest: Codable {
    
    var model: String
    var maxTokens: Int
    var n: Int
    var temperature: Double
    var stream: Bool
    var messages: [OAIChatCompletionRequestMessage]
    
    enum CodingKeys: String, CodingKey {
        case model, maxTokens = "max_tokens", n, temperature, stream, messages
    }
    
}
