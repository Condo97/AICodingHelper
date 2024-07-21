// Constants.swift
// AICodingHelper
// Created by Alex Coundouriotis on 6/26/24.

import Foundation

struct Constants {

    struct Additional {

        static let additionalTokensForEstimationPerFile: Int = 50
        
        static let defaultShareURL = "" // TODO: Put share url here

        static let editSystemMessage = "PLEASE NOTE YOU ARE PERFORMING AN EDIT TASK FOR ONLY THE GIVEN FILE. You may not add other files to it, you will be asked to generate those other files at a later point. You are an AI coding helper service in an IDE so you must format all your responses in code that would be valid in an IDE. Do not include ```LanguageName or ``` to denote code. You only respond with code that is valid in that language. You only respond to the one requested file. All files will be provided in turn, so therefore you will respond to each individually to preserve correct formatting to the IDE since it is looking to receive one file. You may include messages in comments if the langauge supports comments."

    }

    struct IAP {

        static let defaultWeeklyLowProductID = "aicodinghelperweeklylow"
        static let defaultWeeklyMediumProductID = "aicodinghelperweeklymedium"
        static let defaultWeeklyHighProductID = "aicodinghelperweeklyhigh"
        static let defaultMonthlyLowProductID = "aicodinghelpermonthlylow"
        static let defaultMonthlyMediumProductID = "aicodinghelpermonthlymedium"
        static let defaultMonthlyHighProductID = "aicodinghelpermonthlyhigh"
        
        static let defaultWeeklyLowTokenLimit = 10000
        static let defaultWeeklyMediumTokenLimit = 20000
        static let defaultWeeklyHighTokenLimit = 30000
        static let defaultMonthlyLowTokenLimit = 40000
        static let defaultMonthlyMediumTokenLimit = 50000
        static let defaultMonthlyHighTokenLimit = 60000
        
    }

    struct ImageName {

        struct Actions {

            static let bug = "Bug"
            static let simplify = "Simplify"
            static let split = "Split"
            static let createTests = "Create Tests"

        }

    }

    struct Networking {

        struct HTTPS {

            struct Endpoints {

                static let calculateTokens = "/calculateTokens"
                static let generateCode = "/generateCode"
                static let getImportantConstants = "/getImportantConstants"
                static let getIsActive = "/getIsActive"
                static let getRemainingTokens = "/getRemainingTokens"
                static let planCodeGeneration = "/planCodeGeneration"
                static let registerTransaction = "/registerTransaction"
                static let registerUser = "/registerUser"
                static let validateOpenAIKey = "/validateOpenAIKey"

            }

            static let aiCodingHelperServer = "https://chitchatserver.com:9500/v1"

        }

        struct WebSocket {

            struct Endpoints {

                static let getChatStream = "/streamChat"

            }

#if DEBUG
            static let aiCodingHelperWebSocketServer = "wss://chitchatserver.com:9500/v1"//"wss://chitchatserver.com:2000/v1"
#else
            static let aiCodingHelperWebSocketServer = "wss://chitchatserver.com:9500/v1"
#endif

        }

    }

    struct UserDefaults {
        
        static let activeSubscription = "activeSubscription"
        static let authTokenKey = "authTokenKey"
        static let tokensRemaining = "tokensRemaining"

        static let codeEditorTheme = "codeEditorTheme"
        static let generateOptionCopyCurrentFilesToTempFile = "generateOptionCopyCurrentFilesToTempFile"
        static let generateOptionUseEntireProjectAsContext = "generateOptionUseEntireProjectAsContext"
        
        static let isSubscriptionActive = "isSubscriptionActive"
        
        static let openAIKeyIsValid = "openAIKeyIsValid"
        static let openAIKey = "openAIKey"
        
        static let recentProjectFolderBookmarkData = "recentProjectFolderBookmarkData"
        static let weeklyLowProductID = "weeklyLowProductID"
        static let weeklyMediumProductID = "weeklyMediumProductID"
        static let weeklyHighProductID = "weeklyHighProductID"
        static let monthlyLowProductID = "monthlyLowProductID"
        static let monthlyMediumProductID = "monthlyMediumProductID"
        static let monthlyHighProductID = "monthlyHighProductID"

        static let weeklyLowTokenLimit = "weeklyLowTokenLimit"
        static let weeklyMediumTokenLimit = "weeklyMediumTokenLimit"
        static let weeklyHighTokenLimit = "weeklyHighTokenLimit"
        static let monthlyLowTokenLimit = "monthlyLowTokenLimit"
        static let monthlyMediumTokenLimit = "monthlyMediumTokenLimit"
        static let monthlyHighTokenLimit = "monthlyHighTokenLimit"
        
        static let shareURL = "shareURL"
    }

    struct Window {

        static let mainWindowID = "mainWindowID"
        static let homeWindowID = "homeWindowID"

    }

}
