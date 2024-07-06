//
//  OAIChatCompletionResponseMessage.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/6/24.
//

import Foundation


struct OAIChatCompletionResponseMessage: Codable {
    
    let role: CompletionRole
    let content: String? // TODO: Implement
    let toolCalls: [OAIChatCompletionResponseMessageToolCall]
    
    enum CodingKeys: String, CodingKey {
        case role
        case content
        case toolCalls = "tool_calls"
    }
    
}
