//
//  FileCopier.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/1/24.
//

import Foundation


class FileCopier {
    
    static func copyFileToTempVersion(at filepath: String) throws {
        let fileManager = FileManager.default
        let url = URL(fileURLWithPath: filepath)
        guard fileManager.fileExists(atPath: filepath) else {
            throw NSError(domain: "File not found", code: 0, userInfo: nil)
        }
        
        let directory = url.deletingLastPathComponent()
        let filenameWithoutExtension = url.deletingPathExtension().lastPathComponent
        let fileExtension = url.pathExtension
        var destinationURL = directory.appendingPathComponent("\(filenameWithoutExtension)_temp.\(fileExtension)")
        var counter = 1
        
        while fileManager.fileExists(atPath: destinationURL.path) {
            destinationURL = directory.appendingPathComponent("\(filenameWithoutExtension)_temp\(counter).\(fileExtension)")
            counter += 1
        }
        
        try fileManager.copyItem(at: url, to: destinationURL)
    }
    
}
