//
//  OAIChatCompletionResponse.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/6/24.
//

import Foundation


struct OAIChatCompletionResponse: Codable {
    
    let id: String
    let model: String
    let created: Int64
    let usage: OAIChatCompletionResponseUsage
    let choices: [OAIChatCompletionResponseChoice]
    
    enum CodingKeys: String, CodingKey {
        case id
        case model
        case created
        case usage
        case choices
    }
    
}
