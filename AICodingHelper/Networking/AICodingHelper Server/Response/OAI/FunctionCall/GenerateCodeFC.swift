//
//  GenerateCodeFC.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/19/24.
//

import SwiftUI


struct GenerateCodeFC: Codable {
    
    struct File: Codable, Identifiable {
        
        var id = UUID()
        
        var filepath: String
        var content: String
        
        enum CodingKeys: String, CodingKey {
            case filepath
            case content
        }
        
    }
    
    var output_files: [File]
    
    enum CodingKeys: String, CodingKey {
        case output_files
    }
    
}
