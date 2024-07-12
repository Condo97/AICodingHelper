//
//  BookmarkHelper.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/8/24.
//

import Foundation


class BookmarkHelper {
    
    static func getSecurityScopedBookmark(for url: URL) throws -> Data {
        try url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
    }
    
    static func getBookmarkedFile(for data: Data) -> URL? {
        var isStale = false
        do {
            let url = try URL(resolvingBookmarkData: data, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
            
            if isStale {
                print("Bookmark is stale, return nil for now")
                return nil
            }
            
            if url.startAccessingSecurityScopedResource() {
                return url
            } else {
                print("Failed to start accessing security scoped resource")
                return nil
            }
            
        } catch {
            print("Error resolving bookmark: \(error)")
            return nil
        }
    }
    
}
