//
//  OAIChatCompletionRequestMessageContent.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 6/28/24.
//

import Foundation


protocol OAIChatCompletionRequestMessageContent: Codable {
    
    var type: CompletionContentType { get }
    
}
