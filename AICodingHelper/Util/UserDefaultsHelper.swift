//
//  UserDefaultsHelper.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/3/24.
//

import CodeEditor
import Foundation

class UserDefaultsHelper {
    
    static var codeEditorTheme: CodeEditor.ThemeName {
        get {
            CodeEditor.availableThemes.first(where: {$0.rawValue == UserDefaults.standard.string(forKey: Constants.UserDefaults.codeEditorTheme) ?? "atom-one-light"}) ?? CodeEditor.availableThemes.first(where: {$0.rawValue == "atom-one-light"}) ?? .default
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: Constants.UserDefaults.codeEditorTheme)
        }
    }
    
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
    
    static var recentProjectFolderBookmarkData: [Data] {
        get {
            UserDefaults.standard.array(forKey: Constants.UserDefaults.recentProjectFolderBookmarkData) as? [Data] ?? []
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.UserDefaults.recentProjectFolderBookmarkData)
        }
    }

    static var weeklyLowProductID: String {
        get {
            UserDefaults.standard.string(forKey: Constants.UserDefaults.weeklyLowProductID) ?? Constants.IAP.defaultWeeklyLowProductID
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.UserDefaults.weeklyLowProductID)
        }
    }

    static var weeklyMediumProductID: String {
        get {
            UserDefaults.standard.string(forKey: Constants.UserDefaults.weeklyMediumProductID) ?? Constants.IAP.defaultWeeklyMediumProductID
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.UserDefaults.weeklyMediumProductID)
        }
    }

    static var weeklyHighProductID: String {
        get {
            UserDefaults.standard.string(forKey: Constants.UserDefaults.weeklyHighProductID) ?? Constants.IAP.defaultWeeklyHighProductID
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.UserDefaults.weeklyHighProductID)
        }
    }

    static var monthlyLowProductID: String {
        get {
            UserDefaults.standard.string(forKey: Constants.UserDefaults.monthlyLowProductID) ?? Constants.IAP.defaultMonthlyLowProductID
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.UserDefaults.monthlyLowProductID)
        }
    }

    static var monthlyMediumProductID: String {
        get {
            UserDefaults.standard.string(forKey: Constants.UserDefaults.monthlyMediumProductID) ?? Constants.IAP.defaultMonthlyMediumProductID
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.UserDefaults.monthlyMediumProductID)
        }
    }

    static var monthlyHighProductID: String {
        get {
            UserDefaults.standard.string(forKey: Constants.UserDefaults.monthlyHighProductID) ?? Constants.IAP.defaultMonthlyHighProductID
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.UserDefaults.monthlyHighProductID)
        }
    }
    
    static var weeklyLowTokenLimit: Int {
        get {
            UserDefaults.standard.integer(forKey: Constants.UserDefaults.weeklyLowTokenLimit) != 0 ? UserDefaults.standard.integer(forKey: Constants.UserDefaults.weeklyLowTokenLimit) : Constants.IAP.defaultWeeklyLowTokenLimit
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.UserDefaults.weeklyLowTokenLimit)
        }
    }
    
    static var weeklyMediumTokenLimit: Int {
        get {
            UserDefaults.standard.integer(forKey: Constants.UserDefaults.weeklyMediumTokenLimit) != 0 ? UserDefaults.standard.integer(forKey: Constants.UserDefaults.weeklyMediumTokenLimit) : Constants.IAP.defaultWeeklyMediumTokenLimit
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.UserDefaults.weeklyMediumTokenLimit)
        }
    }

    static var weeklyHighTokenLimit: Int {
        get {
            UserDefaults.standard.integer(forKey: Constants.UserDefaults.weeklyHighTokenLimit) != 0 ? UserDefaults.standard.integer(forKey: Constants.UserDefaults.weeklyHighTokenLimit) : Constants.IAP.defaultWeeklyHighTokenLimit
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.UserDefaults.weeklyHighTokenLimit)
        }
    }

    static var monthlyLowTokenLimit: Int {
        get {
            UserDefaults.standard.integer(forKey: Constants.UserDefaults.monthlyLowTokenLimit) != 0 ? UserDefaults.standard.integer(forKey: Constants.UserDefaults.monthlyLowTokenLimit) : Constants.IAP.defaultMonthlyLowTokenLimit
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.UserDefaults.monthlyLowTokenLimit)
        }
    }

    static var monthlyMediumTokenLimit: Int {
        get {
            UserDefaults.standard.integer(forKey: Constants.UserDefaults.monthlyMediumTokenLimit) != 0 ? UserDefaults.standard.integer(forKey: Constants.UserDefaults.monthlyMediumTokenLimit) : Constants.IAP.defaultMonthlyMediumTokenLimit
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.UserDefaults.monthlyMediumTokenLimit)
        }
    }

    static var monthlyHighTokenLimit: Int {
        get {
            UserDefaults.standard.integer(forKey: Constants.UserDefaults.monthlyHighTokenLimit) != 0 ? UserDefaults.standard.integer(forKey: Constants.UserDefaults.monthlyHighTokenLimit) : Constants.IAP.defaultMonthlyHighTokenLimit
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.UserDefaults.monthlyHighTokenLimit)
        }
    }
    
}
