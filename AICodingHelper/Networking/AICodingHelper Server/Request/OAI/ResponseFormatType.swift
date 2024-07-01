//
//  ResponseFormatType.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 6/30/24.
//

import Foundation


enum ResponseFormatType: String, Codable {
    
    case text
    case jsonObject = "json_object"
    
}
