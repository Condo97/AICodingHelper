//
//  UserDefaultsHelper.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/3/24.
//

import Foundation


class UserDefaultsHelper {
    
    static var generateOptionCopyCurrentFilesToTempFile: Bool {
        get {
            UserDefaults.standard.bool(forKey: Constants.UserDefaults.generateOptionCopyCurrentFilesToTempFile)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.UserDefaults.generateOptionCopyCurrentFilesToTempFile)
        }
    }
    
    static var generateOptionUseEntireProjectAsContext: Bool {
        get {
            UserDefaults.standard.bool(forKey: Constants.UserDefaults.generateOptionUseEntireProjectAsContext)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.UserDefaults.generateOptionUseEntireProjectAsContext)
        }
    }
    
    static var recentProjectFolders: [String] {
        get {
            UserDefaults.standard.stringArray(forKey: Constants.UserDefaults.recentProjectFolders) ?? []
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.UserDefaults.recentProjectFolders)
        }
    }
    
}
