//
//  OAIChatCompletionResponseMessageToolCallFunction.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/6/24.
//

import Foundation


struct OAIChatCompletionResponseMessageToolCallFunction: Codable {
    
    let name: String
    let arguments: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case arguments
    }
    
}
