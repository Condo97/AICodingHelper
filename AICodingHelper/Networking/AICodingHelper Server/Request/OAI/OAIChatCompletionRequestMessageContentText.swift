//
//  OAIChatCompletionRequestMessageContentText.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 6/28/24.
//

import Foundation


struct OAIChatCompletionRequestMessageContentText: OAIChatCompletionRequestMessageContent {
    
    let type: CompletionContentType = .text
    let text: String
    
}
