//
//  AICodingHelperHTTPSConnector.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 6/28/24.
//

import Foundation


class AICodingHelperHTTPSConnector: HTTPSClient {
    
    func calculateTokens(request: CalculateTokensRequest) async throws -> CalculateTokensResponse {
        let (data, response) = try await post(
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
    
    func getImportantConstants() async throws -> GetImportantConstantsResponse {
        let (data, response) = try await post(
            url: URL(string: "\(Constants.Networking.HTTPS.aiCodingHelperServer)\(Constants.Networking.HTTPS.Endpoints.getImportantConstants)")!,
            body: BlankRequest(),
            headers: nil)
        
        do {
            let getImportantConstantsResponse = try JSONDecoder().decode(GetImportantConstantsResponse.self, from: data)
            
            return getImportantConstantsResponse
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
    
    func getIsActive(request: AuthRequest) async throws -> IsActiveResponse {
        let (data, response) = try await post(
            url: URL(string: "\(Constants.Networking.HTTPS.aiCodingHelperServer)\(Constants.Networking.HTTPS.Endpoints.getIsActive)")!,
            body: request,
            headers: nil)
        
        do {
            let isActiveResponse = try JSONDecoder().decode(IsActiveResponse.self, from: data)
            
            return isActiveResponse
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
    
    func getRemaining(request: AuthRequest) async throws -> GetRemainingTokensResponse {
        let (data, response) = try await post(
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
    
    func functionCallRequest(endpoint: String, request: FunctionCallRequest) async throws -> OAICompletionResponse {
        let (data, response) = try await post(
            url: URL(string: "\(Constants.Networking.HTTPS.aiCodingHelperServer)\(endpoint)")!,
            body: request,
            headers: nil)
        
        do {
            let oaiCompletionResponse = try JSONDecoder().decode(OAICompletionResponse.self, from: data)
            
            return oaiCompletionResponse
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
            } else if statusResponse.success == 60 {
                throw GenerationError.invalidOpenAIKey
            }
            
            throw error
        }
    }
    
    func registerTransaction(authToken: String, transactionID: UInt64) async throws -> IsActiveResponse {
        let request = RegisterTransactionRequest(authToken: authToken, transactionId: transactionID)
        
        return try await registerTransaction(request: request)
    }
    
    func registerTransaction(request: RegisterTransactionRequest) async throws -> IsActiveResponse {
        let (data, response) = try await post(
            url: URL(string: "\(Constants.Networking.HTTPS.aiCodingHelperServer)\(Constants.Networking.HTTPS.Endpoints.registerTransaction)")!,
            body: request,
            headers: nil)
        
        let isActiveResponse = try JSONDecoder().decode(IsActiveResponse.self, from: data)
        
        return isActiveResponse
    }
    
    func registerUser() async throws -> RegisterUserResponse {
        let (data, response) = try await post(
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
    
    func validateOpenAIKey(request: AuthRequest) async throws -> ValidateOpenAIKeyResponse {
        let (data, response) = try await post(
            url: URL(string: "\(Constants.Networking.HTTPS.aiCodingHelperServer)\(Constants.Networking.HTTPS.Endpoints.validateOpenAIKey)")!,
            body: request,
            headers: nil)
        
        do {
            let validateOpenAIKeyResponse = try JSONDecoder().decode(ValidateOpenAIKeyResponse.self, from: data)
            
            return validateOpenAIKeyResponse
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
