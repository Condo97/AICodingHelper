//
//  AICodingHelperServerHTTPSConnector.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 6/28/24.
//

import Foundation


class AICodingHelperServerHTTPSConnector {
    
    static func registerUser() async throws -> RegisterUserResponse {
        let (data, response) = try await HTTPSClient.post(
            url: URL(string: "\(Constants.Networking.HTTPS.aiCodingHelperServer)\(Constants.Networking.HTTPS.Endpoints.registerUser)")!,
            body: BlankRequest(),
            headers: nil)
        
        do {
            let registerUserResponse = try JSONDecoder().decode(RegisterUserResponse.self, from: data)
            
            return registerUserResponse
        } catch {
            // Catch as StatusResponse
            let statusResponse = try JSONDecoder().decode(StatusResponse.self, from: data)
            
            // Regenerate AuthToken if necessary
            if statusResponse.success == 5 {
                Task {
                    do {
                        try await AuthHelper.regenerate()
                    } catch {
                        print("Error regenerating authToken in HTTPSConnector... \(error)")
                    }
                }
            }
            
            throw error
        }
    }
    
}
