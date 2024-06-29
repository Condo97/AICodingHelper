//
//  OAIChatCompletionRequestMessageContentImageURL.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 6/28/24.
//

import Foundation


struct OAIChatCompletionRequestMessageContentImageURL: OAIChatCompletionRequestMessageContent {
    
    struct ImageURL: Codable {
        
        let url: String
        let detail: InputImageDetail
        
        enum CodingKeys: String, CodingKey {
            case url
            case detail
        }
        
    }
    
    let type: CompletionContentType = .imageURL
    let imageURL: String

    private enum CodingKeys: String, CodingKey {
        case type, imageURL = "image_url"
    }
    
}
