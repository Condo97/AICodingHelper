//
//  OAIChatCompletionRequest.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 6/28/24.
//

import Foundation


struct OAIChatCompletionRequest: Codable {
    
    var model: String
    var maxTokens: Int?
    var n: Int?
    var temperature: Double?
    var responseFormat: OAIChatCompletionRequestResponseFormat?
    var stream: Bool
    var messages: [OAIChatCompletionRequestMessage]
    
    enum CodingKeys: String, CodingKey {
        case model
        case maxTokens = "max_tokens"
        case n
        case temperature
        case responseFormat = "response_format"
        case stream
        case messages
    }
    
}
