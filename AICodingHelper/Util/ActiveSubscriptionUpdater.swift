//
//  ActiveSubscriptionUpdater.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/15/24.
//

import Foundation
import SwiftUI


class ActiveSubscriptionUpdater: ObservableObject {
    
    @Published var isActive: Bool = persistentIsActive
    @Published var subscription: Subscriptions? = persistentSubscription
    @Published var openAIKeyIsValid: Bool = persistentOpenAIKeyIsValid {
        didSet {
            ActiveSubscriptionUpdater.persistentOpenAIKeyIsValid = openAIKeyIsValid
        }
    }
    @Published var openAIKey: String? = persistentOpenAIKey {
        didSet {
            ActiveSubscriptionUpdater.persistentOpenAIKey = openAIKey
        }
    }
    
#if DEBUG
    private static let testOverrideIsActiveTrue = false
    #else
    private static let testOverrideIsActiveTrue = false
#endif
    
    private static var persistentIsActive: Bool {
        get {
            UserDefaults.standard.bool(forKey: Constants.UserDefaults.isSubscriptionActive) || testOverrideIsActiveTrue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.UserDefaults.isSubscriptionActive)
        }
    }
    
    private static var persistentSubscription: Subscriptions? {
        get {
            UserDefaults.standard.object(forKey: Constants.UserDefaults.activeSubscription) as? Subscriptions
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.UserDefaults.activeSubscription)
        }
    }
    
    private static var persistentOpenAIKeyIsValid: Bool {
        get {
            UserDefaults.standard.bool(forKey: Constants.UserDefaults.openAIKeyIsValid)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.UserDefaults.openAIKeyIsValid)
        }
    }
    
    private static var persistentOpenAIKey: String? {
        get {
            UserDefaults.standard.string(forKey: Constants.UserDefaults.openAIKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.UserDefaults.openAIKey)
        }
    }
    
    
    func registerTransaction(authToken: String, transactionID: UInt64) async throws {
        // Get isActiveResponse from server with authToken and transactionID
        let isActiveResponse = try await AICodingHelperHTTPSConnector().registerTransaction(
            authToken: authToken,
            transactionID: transactionID)
        
        // Update with isPremium value
        update(
            isActive: isActiveResponse.body.isActive,
            subscription: isActiveResponse.body.subscription)
    }
    
    func update(authToken: String) async throws {
        // Create authRequest
        let authRequest = AuthRequest(authToken: authToken)

        // Get isActiveResponse from server
        let isActiveResponse = try await AICodingHelperHTTPSConnector().getIsActive(request: authRequest)
        
        // Update with isPremium value
        update(
            isActive: isActiveResponse.body.isActive,
            subscription: isActiveResponse.body.subscription)
    }
    
    private func update(isActive: Bool, subscription: Subscriptions?) {
        // Set persistentIsPremium to isActive and self.isActive to persistentIsActive
        ActiveSubscriptionUpdater.persistentIsActive = isActive
        ActiveSubscriptionUpdater.persistentSubscription = subscription
        
        DispatchQueue.main.async {
            self.isActive = ActiveSubscriptionUpdater.persistentIsActive
            self.subscription = ActiveSubscriptionUpdater.persistentSubscription
        }
    }
    
    
    
}
