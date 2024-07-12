//
//  RecentProjectHelper.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/8/24.
//

import Foundation


class RecentProjectHelper {
    
    static var recentProjectFilepaths: [String] {
        get {
            var recentProjectFilepaths: [String] = []
            let recentProjectFolderBookmarkData = UserDefaultsHelper.recentProjectFolderBookmarkData
            for recentProjectFolderBookmarkDataObject in recentProjectFolderBookmarkData {
                if let url = BookmarkHelper.getBookmarkedFile(for: recentProjectFolderBookmarkDataObject) {
                    // If valid url add its path to recentProjectFilepaths
                    recentProjectFilepaths.append(url.path)
                } else {
                    // If not valid url delete from UserDefaults recentProjectFolderBookmarkData
                    UserDefaultsHelper.recentProjectFolderBookmarkData.removeAll(where: {$0 == recentProjectFolderBookmarkDataObject})
                }
            }
            
            return recentProjectFilepaths
        }
        set {
            var recentProjectFolderBookmarkDataFilenames: [String] = []
            var recentProjectFolderBookmarkData: [Data] = []
            for newValueObject in newValue {
                // Ensure newValueObject is not in recentProjectFolderBookmarkDataFilenames, otherwise continue
                guard !recentProjectFolderBookmarkDataFilenames.contains(newValueObject) else {
                    continue
                }
                
                do {
                    // Append successfully received bookmark to recentProjectFolderBookmarkData
                    recentProjectFolderBookmarkData.append(try BookmarkHelper.getSecurityScopedBookmark(for: URL(fileURLWithPath: newValueObject)))
                    
                    // Append newValueObject to recentProjectFolderBookmarkDataFilenames
                    recentProjectFolderBookmarkDataFilenames.append(newValueObject)
                } catch {
                    // TODO: Handle Errors
                    print("Error getting projectFolderBookmarkData for filepath in RecentProjectHelper, continuing... \(error)")
                }
            }
            
            // Set UserDefaults recentProjectFolderBookmarkData to recentProjectFolderBookmarkData
            UserDefaultsHelper.recentProjectFolderBookmarkData = recentProjectFolderBookmarkData
        }
    }
    
}
