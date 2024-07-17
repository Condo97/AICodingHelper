//
//  UltraView.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/9/24.
//

import StoreKit
import SwiftUI

struct UltraView: View {
    
    @Binding var isPresented: Bool
    
    
    enum SubscriptionLength: String {
        case weekly, monthly
    }
    
    
    @EnvironmentObject private var activeSubscriptionUpdater: ActiveSubscriptionUpdater
    @EnvironmentObject private var productUpdater: ProductUpdater
    @EnvironmentObject private var remainingUpdater: RemainingUpdater
    
    @State private var buttonWidth: CGFloat = 120.0
    @State private var buttonHeight: CGFloat = 150.0
    
    @State private var subscriptionLength: SubscriptionLength = .monthly
    
    @State private var productToPurchase: Product?
    
    @State private var alertShowingErrorLoading: Bool = false
    
    @State private var isLoadingPurchase: Bool = false
    
    @State private var isShowingOpenAIKeyEntry: Bool = false
    
    @State private var openAIKeyEntryText: String = ""
    
    @State private var errorPurchasing: Error?
    
    private var lowProduct: Product? {
        switch subscriptionLength {
        case .weekly:
            productUpdater.weeklyLowProduct
        case .monthly:
            productUpdater.monthlyLowProduct
        }
    }
    
    private var mediumProduct: Product? {
        switch subscriptionLength {
        case .weekly:
            productUpdater.weeklyMediumProduct
        case .monthly:
            productUpdater.monthlyMediumProduct
        }
    }
    
    private var highProduct: Product? {
        switch subscriptionLength {
        case .weekly:
            productUpdater.weeklyHighProduct
        case .monthly:
            productUpdater.monthlyHighProduct
        }
    }
    
    private var lowTokenLimit: Int {
        switch subscriptionLength {
        case .weekly:
            UserDefaultsHelper.weeklyLowTokenLimit
        case .monthly:
            UserDefaultsHelper.monthlyLowTokenLimit
        }
    }

    private var mediumTokenLimit: Int {
        switch subscriptionLength {
        case .weekly:
            UserDefaultsHelper.weeklyMediumTokenLimit
        case .monthly:
            UserDefaultsHelper.monthlyMediumTokenLimit
        }
    }

    private var highTokenLimit: Int {
        switch subscriptionLength {
        case .weekly:
            UserDefaultsHelper.weeklyHighTokenLimit
        case .monthly:
            UserDefaultsHelper.monthlyHighTokenLimit
        }
    }
    
    private var lowSubscriptionActive: Bool {
        switch subscriptionLength {
        case .weekly:
            activeSubscriptionUpdater.subscription == .lowWeekly
        case .monthly:
            activeSubscriptionUpdater.subscription == .lowMonthly
        }
    }
    
    private var mediumSubscriptionActive: Bool {
        switch subscriptionLength {
        case .weekly:
            activeSubscriptionUpdater.subscription == .mediumWeekly
        case .monthly:
            activeSubscriptionUpdater.subscription == .mediumMonthly
        }
    }
    
    private var highSubscriptionActive: Bool {
        switch subscriptionLength {
        case .weekly:
            activeSubscriptionUpdater.subscription == .highWeekly
        case .monthly:
            activeSubscriptionUpdater.subscription == .highMonthly
        }
    }
    
    var body: some View {
        VStack {
            if activeSubscriptionUpdater.isActive {
                Text("You Are Subscribed")
                    .font(.title)
                    .padding(.bottom, 4)
                
                Text("Change your subscription to get more tokens.")
                    .font(.headline)
            } else {
                Text("Upgrade")
                    .font(.title)
                    .padding(.bottom, 4)
                
                Text("Code more effectively. Subscribe to get tokens.")
                    .font(.headline)
            }
            
            Text("Directly supports the developer. Cheaper than ChatGPT.")
                .font(.subheadline)
                .italic()
                .opacity(0.6)
            
            Picker(selection: $subscriptionLength, content: {
                Text("Weekly")
                    .tag(SubscriptionLength.weekly)
                
                Text("Monthly 30% OFF")
                    .tag(SubscriptionLength.monthly)
            }, label: {
                
            })
            .frame(maxWidth: 200.0)
            .pickerStyle(.segmented)
            
            HStack {
                // Low
                if let lowProduct = lowProduct {
                    Button(action: {
                        productToPurchase = lowProduct
                        purchase()
                    }) {
                        VStack {
                            Text("Basic")
                                .font(.title2)
                                .bold()
                            
                            if lowSubscriptionActive {
                                Text("Active")
                                    .font(.title3)
                                    .italic()
                                    .padding(.bottom, 8)
                            } else {
                                Text(lowProduct.displayPrice)
                                    .font(.title3)
                                    .padding(.bottom, 8)
                            }
                            
                            Text("\(lowTokenLimit)")
                                .font(.title)
                                .bold()
                            
                            Text("Tokens / \(subscriptionLength.rawValue.capitalized)")
                                .font(.subheadline)
                                .opacity(0.6)
                        }
                        .frame(width: buttonWidth, height: buttonHeight)
                    }
                    .disabled(lowSubscriptionActive)
                    .overlay {
                        if lowSubscriptionActive {
                            Image(systemName: "checkmark.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: 38.0)
                                .foregroundStyle(.white, .green)
                        }
                    }
                }
                
                // Medium
                if let mediumProduct = mediumProduct {
                    Button(action: {
                        productToPurchase = mediumProduct
                        purchase()
                    }) {
                        VStack {
                            Text("Advanced")
                                .font(.title2)
                                .bold()
                                .foregroundStyle(.element)
                            
                            if mediumSubscriptionActive {
                                Text("Active")
                                    .font(.title3)
                                    .italic()
                                    .padding(.bottom, 8)
                            } else {
                                Text(mediumProduct.displayPrice)
                                    .font(.title3)
                                    .padding(.bottom, 8)
                            }
                            
                            Text("\(mediumTokenLimit)")
                                .font(.title)
                                .bold()
                            
                            Text("Tokens / \(subscriptionLength.rawValue.capitalized)")
                                .font(.subheadline)
                                .opacity(0.6)
                        }
                        .frame(width: buttonWidth, height: buttonHeight)
                    }
                    .disabled(mediumSubscriptionActive)
                    .overlay {
                        if mediumSubscriptionActive {
                            Image(systemName: "checkmark.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: 38.0)
                                .foregroundStyle(.white, .green)
                        }
                    }
                }
                
                // High
                if let highProduct = highProduct {
                    Button(action: {
                        productToPurchase = highProduct
                        purchase()
                    }) {
                        VStack {
                            Text("Ultra")
                                .font(.title2)
                                .bold()
                                .foregroundStyle(LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing))
                            
                            if highSubscriptionActive {
                                Text("Active")
                                    .font(.title3)
                                    .italic()
                                    .padding(.bottom, 8)
                            } else {
                                Text(highProduct.displayPrice)
                                    .font(.title3)
                                    .padding(.bottom, 8)
                            }
                            
                            Text("\(highTokenLimit)")
                                .font(.title)
                                .bold()
                            
                            Text("Tokens / \(subscriptionLength.rawValue.capitalized)")
                                .font(.subheadline)
                                .opacity(0.6)
                        }
                        .frame(width: buttonWidth, height: buttonHeight)
                    }
                    .disabled(highSubscriptionActive)
                    .overlay {
                        if highSubscriptionActive {
                            Image(systemName: "checkmark.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: 38.0)
                                .foregroundStyle(.white, .green)
                        }
                    }
                }
            }
            
            // Open AI API Key
            if let openAIKey = activeSubscriptionUpdater.openAIKey {
                HStack {
                    Text("OpenAI API Key")
                    
                    HStack {
                        Button("Change") {
                            isShowingOpenAIKeyEntry = true
                        }
                        
                        Button("Delete") {
                            activeSubscriptionUpdater.openAIKey = nil
                        }
                        .foregroundStyle(.red)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .underline()
                }
                .font(.subheadline)
                .padding(.top, 4)
                
                Text(openAIKey)
                    .font(.system(size: 9.0))
                    .opacity(0.6)
                    .foregroundStyle(activeSubscriptionUpdater.openAIKeyIsValid ? .foregroundText : .red)
                    .padding(.top, 2)
                
                if !activeSubscriptionUpdater.openAIKeyIsValid {
                    Text("**Invalid API Key!** - Currently Using Your Plan")
                        .font(.subheadline)
                        .padding(.top, 2)
                }
            } else {
                HStack {
                    Text("Or,")
                    Button("Use Your OpenAI API Key") {
                        isShowingOpenAIKeyEntry = true
                    }
                    .buttonStyle(PlainButtonStyle())
                    .underline()
                }
                .font(.subheadline)
                .padding(.top, 4)
            }
        }
        .overlay {
            VStack {
                HStack {
                    Spacer()
                    Button("\(Image(systemName: "xmark"))") {
                        isPresented = false
                    }
                }
                Spacer()
            }
        }
        .padding()
        .sheet(isPresented: $isShowingOpenAIKeyEntry) {
            OpenAIKeyEntryView(isPresented: $isShowingOpenAIKeyEntry)
        }
        .alert("Error Purchasing", isPresented: $alertShowingErrorLoading, actions: {
            Button("Cancel", role: .cancel) {
                
            }
            
            Button("Try Again", role: .none) {
                purchase()
            }
        }, message: {
            
        })
    }
    
    
    func purchase() {
        // Ensure product as productToPurchase otherwise return
        guard let product = productToPurchase else {
            return
        }
        
        Task {
            defer {
                isLoadingPurchase = false
            }
            
            // Set isLoadingPurchase to true
            await MainActor.run {
                isLoadingPurchase = true
            }
            
            // Unwrap authToken
            guard let authToken = try? await AuthHelper.ensure() else {
                // If the authToken is nil, show an error alert that the app can't connect to the server and return
                alertShowingErrorLoading = true
                return
            }
            
            // Purchase
            let transaction: StoreKit.Transaction
            do {
                transaction = try await IAPManager.purchase(product)
            } catch {
                // TODO: Handle errors
                print("Error purchasing product in UltraView... \(error)")
                errorPurchasing = error
                return
            }
            
            // Register the transaction ID
            do {
                try await activeSubscriptionUpdater.registerTransaction(
                    authToken: authToken,
                    transactionID: transaction.originalID)
            } catch {
                // TODO: Handle Errors
                print("Error registering transaction in UltraView... \(error)")
                errorPurchasing = error
                return
            }
            
            // Update remaining
            do {
                try await remainingUpdater.update(authToken: authToken)
            } catch {
                // TODO: Handle Errors
                print("Error updating remaining in UltraView... \(error)")
            }
            
            // Dismiss if active subscription after a small delay
            if activeSubscriptionUpdater.isActive {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    withAnimation {
                        isPresented = false
                    }
                }
            }
        }
    }
    
    func restore() async throws {
        defer {
            DispatchQueue.main.async {
                isLoadingPurchase = false
            }
        }
        
        await MainActor.run {
            isLoadingPurchase = true
        }
        
        try await AppStore.sync()
    }
    
}

#Preview {
    
    UltraView(isPresented: .constant(true))
        .environmentObject(ActiveSubscriptionUpdater())
        .environmentObject(ProductUpdater())
        .frame(width: 550.0, height: 500.0)
    
}
