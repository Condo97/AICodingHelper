//
//  OAIChatCompletionRequestResponseFormat.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 6/30/24.
//

import Foundation


struct OAIChatCompletionRequestResponseFormat: Codable {
    
    var type: ResponseFormatType
    
    enum CodingKeys: String, CodingKey {
        case type
    }
    
}
