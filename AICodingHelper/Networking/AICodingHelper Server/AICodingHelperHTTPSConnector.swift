//
//  AICodingHelperHTTPSConnector.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 6/28/24.
//

import Foundation


class AICodingHelperHTTPSConnector {
    
    static func calculateTokens(request: CalculateTokensRequest) async throws -> CalculateTokensResponse {
        let (data, response) = try await HTTPSClient.post(
            url: URL(string: "\(Constants.Networking.HTTPS.aiCodingHelperServer)\(Constants.Networking.HTTPS.Endpoints.calculateTokens)")!,
            body: request,
            headers: nil)
        
        do {
            let calculateTokensResponse = try JSONDecoder().decode(CalculateTokensResponse.self, from: data)
            
            return calculateTokensResponse
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
    
    static func getRemaining(request: AuthRequest) async throws -> GetRemainingTokensResponse {
        let (data, response) = try await HTTPSClient.post(
            url: URL(string: "\(Constants.Networking.HTTPS.aiCodingHelperServer)\(Constants.Networking.HTTPS.Endpoints.getRemainingTokens)")!,
            body: request,
            headers: nil)
        
        do {
            let getRemainingResponse = try JSONDecoder().decode(GetRemainingTokensResponse.self, from: data)
            
            return getRemainingResponse
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
