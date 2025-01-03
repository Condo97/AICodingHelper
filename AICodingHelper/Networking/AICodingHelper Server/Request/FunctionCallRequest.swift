//
//  FunctionCallRequest.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/6/24.
//

import Foundation


struct FunctionCallRequest: Codable {
    
    let authToken: String
    let openAIKey: String?
    let model: GPTModels
    let messages: [OAIChatCompletionRequestMessage]
//    let systemMessage: String?
//    let input: String
    
    enum CodingKeys: String, CodingKey {
        case authToken
        case openAIKey
        case model
        case messages
//        case systemMessage
//        case input
    }
    
}
