//
//  GenerateOptions.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/1/24.
//
// https://developer.apple.com/documentation/swift/optionset

import Foundation


// Allows for a: GenerateOptions = .useEntireProjectAsContext or a: GenerateOptions = [.useEntireProjectAsContext, .copyCurrentFilesToTempFiles]. Check by doing contains the value here
struct GenerateOptions: OptionSet {
    let rawValue: Int
    
    static let copyCurrentFilesToTempFiles = GenerateOptions(rawValue: 1 << 0)
    static let useEntireProjectAsContext = GenerateOptions(rawValue: 1 << 1)
}
