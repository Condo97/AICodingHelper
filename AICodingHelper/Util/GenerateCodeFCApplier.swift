//
//  GenerateCodeFCApplier.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/25/24.
//

import Foundation


class GenerateCodeFCApplier {
    
    static func apply(_ generateCodeFC: GenerateCodeFC, rootFilepath: String) {
        // Apply changes
        for file in generateCodeFC.output_files {
            let relativeFilepath = file.filepath.replacingOccurrences(of: rootFilepath, with: "")
            let fullFilepath = URL(fileURLWithPath: rootFilepath).appendingPathComponent(relativeFilepath, conformingTo: .text).path
            
            FileCreator.createFile(
                filepath: fullFilepath,
                content: file.content)
        }
    }
    
}
