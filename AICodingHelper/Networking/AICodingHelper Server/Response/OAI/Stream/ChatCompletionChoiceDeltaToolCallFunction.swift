//
//  ChatCompletionChoiceDeltaToolCallFunction.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/29/24.
//

import Foundation


struct ChatCompletionChoiceDeltaToolCallFunction: Codable {
    
    let name: String?
    let arguments: String?
    
    enum CodingKeys: String, CodingKey {
        case name, arguments
    }
    
}
