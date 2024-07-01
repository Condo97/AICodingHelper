//
//  FileSystem+Printer.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/1/24.
//

import Foundation


extension FileSystem {
    
    func stringifyContent(rootDirectory: String) -> String {
        // Get filepath from rootDirectory and name
        let filepath = rootDirectory + "/" + self.name
        var result = ""

        // Check if the current object is a file or a directory
        if let subfiles = subfiles {
            // Directory case: Recursively process each subfile
            for subfile in subfiles {
                result += subfile.stringifyContent(rootDirectory: filepath)
            }
        } else {
            // File case: Read content from the file at filepath
            do {
            let fileContent = try String(contentsOfFile: filepath)
                result += "Path: \(filepath)\n"
                result += "Content:\n\(fileContent)\n"
                result += "---------------------------------\n"
            } catch {
                result += "Path: \(filepath)\n"
                    result += "Error reading file: \(error.localizedDescription)\n"
                result += "---------------------------------\n"
            }
        }
        
        return result
    }
    
}
