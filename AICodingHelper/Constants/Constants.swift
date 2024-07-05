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
