//
//  Scope.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 6/26/24.
//

import Foundation

enum Scope {
    case project
    case multifile
    case directory
    case file
    case highlight
}

extension Scope {
    
    var name: String {
        switch self {
        case .project: "project"
        case .multifile: "files"
        case .directory: "folder"
        case .file: "file"
        case .highlight: "highlight"
        }
    }
    
}
