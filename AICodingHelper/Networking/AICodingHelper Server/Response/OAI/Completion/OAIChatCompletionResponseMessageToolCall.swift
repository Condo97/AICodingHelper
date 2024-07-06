//
//  OAIChatCompletionResponseMessageToolCall.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/6/24.
//

import Foundation


struct OAIChatCompletionResponseMessageToolCall: Codable {
    
    let id: String
    let type: String // TODO: Convert to enum probably lol
    let function: OAIChatCompletionResponseMessageToolCallFunction
    
    enum CodingKeys: String, CodingKey {
        case id
        case type
        case function
    }
    
}
