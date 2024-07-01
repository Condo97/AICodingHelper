//
//  FileSystem.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 6/30/24.
//

import Foundation

class FileSystem: Codable {
    
    var name: String
    var subfiles: [FileSystem]?
    
    init(name: String, subfiles: [FileSystem]? = nil) {
        self.name = name
        self.subfiles = subfiles
    }
    
    enum CodingKeys: String, CodingKey {
        case name
        case subfiles
    }
    
}


extension FileSystem {
    
    enum FileType {
        case file
        case folder
    }
    
    var fileType: FileType {
        subfiles == nil ? .file : .folder
    }
    
    static func from(parentName: String, paths: [String]) -> FileSystem? {
        // Create FileSystem for each path in paths
        var fileSystems = paths.compactMap({from(path: $0)})
        
        // Return fileSystems in FileSystem with name parentName and type folder
        return FileSystem(
            name: parentName,
            subfiles: fileSystems)
    }
    
    static func from(path: String) -> FileSystem? {
        let fileManager = FileManager.default
            
        var isDirectory: ObjCBool = false
        guard fileManager.fileExists(atPath: path, isDirectory: &isDirectory) else {
            return nil
        }

        let name = (path as NSString).lastPathComponent
        
        if isDirectory.boolValue {
            let fileSystem = FileSystem(name: name)
            
            do {
                let contents = try fileManager.contentsOfDirectory(atPath: path)
                var children: [FileSystem] = []
                for item in contents {
                    if let itemPath = (path as NSString?).map({ $0.appendingPathComponent(item) }) {
                        if let child = from(path: itemPath) {
                            children.append(child)
                        }
                    }
                }
                fileSystem.subfiles = children
            } catch {
                print("Failed to list directory contents: \(error)")
            }

            return fileSystem
            
        } else {
            return FileSystem(name: name)
        }
    }
    
}
