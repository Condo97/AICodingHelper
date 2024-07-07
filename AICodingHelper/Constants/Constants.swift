//
//  Constants.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 6/26/24.
//

import Foundation

struct Constants {
    
    struct Additional {
        
        static let additionalTokensForEstimationPerFile: Int = 50
        
        static let editSystemMessage = "PLEASE NOTE YOU ARE PERFORMING AN EDIT TASK FOR ONLY THE GIVEN FILE. You may not add other files to it, you will be asked to generate those other files at a later point. You are an AI coding helper service in an IDE so you must format all your responses in code that would be valid in an IDE. Do not include ```LanguageName or ``` to denote code. You only respond with code that is valid in that language. You only respond to the one requested file. All files will be provided in turn, so therefore you will respond to each individually to preserve correct formatting to the IDE since it is looking to receive one file."
        
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
                static let getRemainingTokens = "/getRemainingTokens"
                static let planCodeGeneration = "/planCodeGeneration"
                static let registerUser = "/registerUser"
                
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
        
        static let authTokenKey = "authTokenKey"
        static let tokensRemaining = "tokensRemaining"
        
        static let generateOptionCopyCurrentFilesToTempFile = "generateOptionCopyCurrentFilesToTempFile"
        static let generateOptionUseEntireProjectAsContext = "generateOptionUseEntireProjectAsContext"
    }
    
}
