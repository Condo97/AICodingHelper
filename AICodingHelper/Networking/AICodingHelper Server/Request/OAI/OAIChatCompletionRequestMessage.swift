//
//  OAIChatCompletionRequestMessage.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 6/28/24.
//

import Foundation


struct OAIChatCompletionRequestMessage: Codable {
    
    var role: CompletionRole
    var content: [OAIChatCompletionRequestMessageContentType]
    
    enum CodingKeys: String, CodingKey {
        case role
        case content
    }
    
}
