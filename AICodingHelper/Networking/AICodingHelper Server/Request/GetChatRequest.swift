//
//  GetChatRequest.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 6/28/24.
//

import Foundation

struct GetChatRequest: Encodable {
    
    var authToken: String
    var chatCompletionRequest: OAIChatCompletionRequest
    
    enum CodingKeys: String, CodingKey {
        case authToken
        case chatCompletionRequest
    }
    
}
