//
//  OAIChatCompletionResponseChoice.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/6/24.
//

import Foundation


struct OAIChatCompletionResponseChoice: Codable {
    
    let finishReason: String
    let index: Int
    let message: OAIChatCompletionResponseMessage
    
    enum CodingKeys: String, CodingKey {
        case finishReason = "finish_reason"
        case index
        case message
    }
    
}
