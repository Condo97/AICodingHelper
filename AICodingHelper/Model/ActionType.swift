//
//  ActionType.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 6/26/24.
//

import Foundation

enum ActionType {
    
    case comment
    case bugFix
    case split
    case simplify
    case createTests
    case custom
    
}


extension ActionType {
    
    var name: String {
        switch self {
        case .comment:
            "comment"
        case .bugFix:
            "bug fix"
        case .split:
            "split"
        case .simplify:
            "simplify"
        case .createTests:
            "create tests"
        case .custom:
            "custom"
        }
    }
    
    var aiPrompt: String {
        switch self {
        case .comment:
            "Comment the following code."
        case .bugFix:
            "Bug fix the following code."
        case .split:
            "Split the following code into smaller components."
        case .simplify:
            "Simplify the following code"
        case .createTests:
            "Create tests for the following code"
        case .custom:
            ""
        }
    }
    
}
