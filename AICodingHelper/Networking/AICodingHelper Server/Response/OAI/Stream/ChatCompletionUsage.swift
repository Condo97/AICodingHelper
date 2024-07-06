//
//  ChatCompletionUsage.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 6/28/24.
//

import Foundation


struct ChatCompletionUsage: Codable {
    
    let completionTokens: Int?
    let promptTokens: Int?
    let totalTokens: Int?

    private enum CodingKeys: String, CodingKey {
        case completionTokens = "completion_tokens", promptTokens = "prompt_tokens", totalTokens = "total_tokens"
    }
    
}
