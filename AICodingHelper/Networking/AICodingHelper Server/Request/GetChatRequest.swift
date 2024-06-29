//
//  GetChatRequest.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 6/28/24.
//

import Foundation

struct GetChatRequest: Encodable {
    
    var chatCompletionRequest: OAIChatCompletionRequest
    
    enum CodingKeys: String, CodingKey {
        case chatCompletionRequest
    }
    
}
