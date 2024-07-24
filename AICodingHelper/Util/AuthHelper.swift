//
//  AuthHelper.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/30/23.
//

import Foundation

class AuthHelper {
    
    static func get() -> String? {
        return UserDefaults.standard.string(forKey: Constants.UserDefaults.authTokenKey)
    }
    
    /***
     Ensure - Gets the authToken either from the server or locally
     
     throws
        - If the client cannot get the AuthToken from the server and there is no AuthToken available locally
     */
    static func ensure() async throws -> String {
        // If no authToken, register the user and update the authToken in UserDefaults
        if UserDefaults.standard.string(forKey: Constants.UserDefaults.authTokenKey) == nil {
            let registerUserResponse = try await AICodingHelperHTTPSConnector().registerUser()
            
            UserDefaults.standard.set(registerUserResponse.body.authToken, forKey: Constants.UserDefaults.authTokenKey)
        }
        
        return UserDefaults.standard.string(forKey: Constants.UserDefaults.authTokenKey)!
    }
    
    /***
     Regenerate - Deletes current authToken and gets a new one from the server
     
     throws
        - If the client cannot get the AuthToken from the server and there is no AuthToken available locally
     */
    @discardableResult
    static func regenerate() async throws -> String {
        UserDefaults.standard.set(nil, forKey: Constants.UserDefaults.authTokenKey)
        
        let registerUserResponse = try await AICodingHelperHTTPSConnector().registerUser()
        
        UserDefaults.standard.set(registerUserResponse.body.authToken, forKey: Constants.UserDefaults.authTokenKey)
        
        return UserDefaults.standard.string(forKey: Constants.UserDefaults.authTokenKey)!
    }
    
}
