//
//  ChatCompletionChoiceDeltaFunctionCall.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/29/24.
//

import Foundation


struct ChatCompletionChoiceDeltaToolCall: Codable {
    
    let index: Int?
    let id: String?
    let type: String?
    let function: ChatCompletionChoiceDeltaToolCallFunction
    
    enum CodingKeys: String, CodingKey {
        case index, id, type, function
    }
    
}
