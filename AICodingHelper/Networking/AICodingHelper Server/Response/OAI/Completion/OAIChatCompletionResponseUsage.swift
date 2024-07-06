//
//  OAIChatCompletionResponseUsage.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/6/24.
//

import Foundation


struct OAIChatCompletionResponseUsage: Codable {
    
    let promptTokens: Int64
    let completionTokens: Int64
    let totalTokens: Int64
    
    enum CodingKeys: String, CodingKey {
        case promptTokens = "prompt_tokens"
        case completionTokens = "completion_tokens"
        case totalTokens = "total_tokens"
    }
    
}
