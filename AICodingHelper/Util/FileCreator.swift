//
//  FileCreator.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/21/24.
//

import Foundation


class FileCreator {
    
    static func createFile(filepath: String, content: String) {
        let fileManager = FileManager.default
        
        // Extract the directory path from the full file path
        let directoryPath = (filepath as NSString).deletingLastPathComponent

        // Create the directory if it doesn't exist
        if !fileManager.fileExists(atPath: directoryPath) {
            do {
                try fileManager.createDirectory(atPath: directoryPath, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Error creating directory: \(error.localizedDescription)")
                return
            }
        }
        
        // Create the file with the specified content
        let data = content.data(using: .utf8)
        fileManager.createFile(atPath: filepath, contents: data, attributes: nil)
    }
    
}
