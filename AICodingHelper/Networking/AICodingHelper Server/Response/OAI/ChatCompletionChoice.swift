//
//  ChatCompletionChoice.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 6/28/24.
//

import Foundation


struct ChatCompletionChoice: Codable {
    
    let index: Int
    let delta: ChatCompletionDelta
    let finishReason: String?

    private enum CodingKeys: String, CodingKey {
        case index, delta, finishReason = "finish_reason"
    }
    
}
