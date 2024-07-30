//
//  FilePrettyPrinter.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/1/24.
//

import Foundation


class FilePrettyPrinter {
    
    static func getFileContent(relativeFilepath: String, rootFilepath: String?) -> String {
        var result = ""
        let fileManager = FileManager.default
        
        let fullFilepath = rootFilepath == nil ? relativeFilepath : (rootFilepath! + (relativeFilepath.hasPrefix("/") ? "" : "/") + relativeFilepath)

        // Check if the given path is a directory
        var isDirectory: ObjCBool = false
        if fileManager.fileExists(atPath: fullFilepath, isDirectory: &isDirectory) {
            if isDirectory.boolValue {
                // Directory case: Recursively process each subfile
                do {
                    let subfiles = try fileManager.contentsOfDirectory(atPath: fullFilepath)
                    for subfile in subfiles {
                        let subfilePath = (relativeFilepath as NSString).appendingPathComponent(subfile)
                        result += getFileContent(relativeFilepath: subfilePath, rootFilepath: rootFilepath)
                    }
                } catch {
                    result += "Path: \(relativeFilepath)\n" // Relative filepath here in the print
                    result += "Error reading directory: \(error.localizedDescription)\n"
                    result += "---------------------------------\n"
                }
            } else {
                // File case: Read content from the file at filepath
                do {
                    let fileContent = try String(contentsOfFile: fullFilepath)
                    result += "Path: \(relativeFilepath)\n" // Relative filepath here in the print
                    result += "Content:\n\(fileContent)\n"
                    result += "---------------------------------\n"
                } catch {
                    result += "Path: \(relativeFilepath)\n" // Relative filepath here in the print
                    result += "Error reading file: \(error.localizedDescription)\n"
                    result += "---------------------------------\n"
                }
            }
        } else {
            result += "Path: \(relativeFilepath)\n" // Relative filepath here in the print
            result += "File does not exist.\n"
            result += "---------------------------------\n"
        }
        
        return result
    }
    
}
