//
//  ChatCompletionDelta.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 6/28/24.
//

import Foundation


struct ChatCompletionDelta: Codable {
    
    let role: String?
    let content: String?

    private enum CodingKeys: String, CodingKey {
        case role, content
    }
    
}
