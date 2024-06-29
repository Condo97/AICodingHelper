//
//  ChatCompletionChunk.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 6/28/24.
//

import Foundation


struct ChatCompletionChunk: Codable {
    
    let id: String
    let object: String
    let created: Int
    let model: String
    let systemFingerprint: String?
    let choices: [ChatCompletionChoice]
    let serviceTier: String?
    let usage: ChatCompletionUsage?

    private enum CodingKeys: String, CodingKey {
        case id, object, created, model, systemFingerprint = "system_fingerprint", choices, serviceTier = "service_tier", usage
    }
    
}
