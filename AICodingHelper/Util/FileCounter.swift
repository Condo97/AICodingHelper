//
//  FileCounter.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/3/24.
//

import Foundation


class FileCounter {
    
    static func countFiles(paths: [String], recursive: Bool = true) -> Int {
        let fileManager = FileManager.default
        
        // Cool usage of a nested function GPT :)
        func countFilesInDirectory(path: String) -> Int {
            // Check if the path is a directory
            var isDirectory: ObjCBool = false
            guard fileManager.fileExists(atPath: path, isDirectory: &isDirectory), isDirectory.boolValue else {
                return 0
            }

            var fileCount = 0

            // Get the contents of the directory
            do {
                let contents = try fileManager.contentsOfDirectory(atPath: path)
                for item in contents {
                    let itemPath = (path as NSString).appendingPathComponent(item)
                    var isDir: ObjCBool = false
                    if fileManager.fileExists(atPath: itemPath, isDirectory: &isDir) {
                        if isDir.boolValue {
                            if recursive {
                            // Recursively count files in subdirectory
                                fileCount += countFilesInDirectory(path: itemPath)
                            }
                        } else {
                            // Count this file
                            fileCount += 1
                        }
                    }
                }
            } catch {
                print("Error while enumerating files in directory \(path): \(error.localizedDescription)")
            }

            return fileCount
        }

        var totalFileCount = 0

        for path in paths {
            totalFileCount += countFilesInDirectory(path: path)
        }

        return totalFileCount
    }
    
}
