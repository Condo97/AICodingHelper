//
//  ChatCompletionChoiceDelta.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 6/28/24.
//

import Foundation


struct ChatCompletionChoiceDelta: Codable {
    
    let role: String?
    let content: String?
    let toolCalls: [ChatCompletionChoiceDeltaToolCall]?

    private enum CodingKeys: String, CodingKey {
        case role, content, toolCalls = "tool_calls"
    }
    
}
