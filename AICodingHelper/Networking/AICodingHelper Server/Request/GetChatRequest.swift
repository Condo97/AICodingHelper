//
//  GetChatRequest.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 6/28/24.
//

import Foundation

struct GetChatRequest: Encodable {
    
    var authToken: String
    var openAIKey: String?
    var chatCompletionRequest: OAIChatCompletionRequest
    var function: String?
    
    enum CodingKeys: String, CodingKey {
        case authToken
        case openAIKey
        case chatCompletionRequest
        case function
    }
    
}
