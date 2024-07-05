//
//  FilePrettyPrinter.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/1/24.
//

import Foundation


class FilePrettyPrinter {
    
    static func getFileContent(filepath: String) -> String {
        var result = ""
        let fileManager = FileManager.default

        // Check if the given path is a directory
        var isDirectory: ObjCBool = false
        if fileManager.fileExists(atPath: filepath, isDirectory: &isDirectory) {
            if isDirectory.boolValue {
                // Directory case: Recursively process each subfile
                do {
                    let subfiles = try fileManager.contentsOfDirectory(atPath: filepath)
                    for subfile in subfiles {
                        let subfilePath = (filepath as NSString).appendingPathComponent(subfile)
                        result += getFileContent(filepath: subfilePath)
                    }
                } catch {
                    result += "Path: \(filepath)\n"
                    result += "Error reading directory: \(error.localizedDescription)\n"
                    result += "---------------------------------\n"
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
        } else {
            result += "Path: \(filepath)\n"
            result += "File does not exist.\n"
            result += "---------------------------------\n"
        }
        
        return result
    }
    
}
