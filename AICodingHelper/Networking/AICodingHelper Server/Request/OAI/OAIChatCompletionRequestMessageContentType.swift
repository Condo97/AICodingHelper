//
//  OAIChatCompletionRequestMessageContentType.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 6/28/24.
//

import Foundation


enum OAIChatCompletionRequestMessageContentType: Codable {
    
    case text(OAIChatCompletionRequestMessageContentText)
    case imageURL(OAIChatCompletionRequestMessageContentImageURL)

    private enum CodingKeys: String, CodingKey {
        case type, text, imageURL = "image_url"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(CompletionContentType.self, forKey: .type)

        switch type {
        case .text:
            let textContent = try OAIChatCompletionRequestMessageContentText(from: decoder)
            self = .text(textContent)
        case .imageURL:
            let imageURLContent = try OAIChatCompletionRequestMessageContentImageURL(from: decoder)
            self = .imageURL(imageURLContent)
        }
    }

    func encode(to encoder: Encoder) throws {
        switch self {
        case .text(let textContent):
            try textContent.encode(to: encoder)
        case .imageURL(let imageURLContent):
            try imageURLContent.encode(to: encoder)
        }
    }
    
}
