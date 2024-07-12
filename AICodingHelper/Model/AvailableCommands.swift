//
//  AvailableCommands.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/8/24.
//
// https://developer.apple.com/documentation/swift/optionset

import Foundation


// Allows for a: GenerateOptions = .useEntireProjectAsContext or a: GenerateOptions = [.useEntireProjectAsContext, .copyCurrentFilesToTempFiles]. Check by doing contains the value here
struct AvailableCommands: OptionSet {
    let rawValue: Int
    
    static let newAIProject = AvailableCommands(rawValue: 1 << 0)
    static let newBlankProject = AvailableCommands(rawValue: 1 << 1)
    static let openProject = AvailableCommands(rawValue: 1 << 2)
    static let newAIFile = AvailableCommands(rawValue: 1 << 3)
    static let newBlankFile = AvailableCommands(rawValue: 1 << 4)
    static let newFolder = AvailableCommands(rawValue: 1 << 5)
    static let openFolder = AvailableCommands(rawValue: 1 << 6)
    
    static let all: AvailableCommands = [
        .newAIProject,
        .newBlankProject,
        .openProject,
        .newAIFile,
        .newBlankFile,
        .newFolder,
        .openFolder
    ]
    
    static let project: AvailableCommands = [
        .newAIProject,
        .newBlankProject,
        .openProject
    ]
    
}
