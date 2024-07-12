//
//  UltraView.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/9/24.
//

import StoreKit
import SwiftUI

struct UltraView: View {
    
    enum SubscriptionLength: String {
        case weekly, monthly
    }
    
    
    @EnvironmentObject private var productUpdater: ProductUpdater
    
    @State private var buttonWidth: CGFloat = 100.0
    @State private var buttonHeight: CGFloat = 150.0
    
    @State private var subscriptionLength: SubscriptionLength = .monthly
    
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
    
    var body: some View {
        VStack {
            Text("Upgrade")
                .font(.title)
            
            Text("Code more effectively.")
            
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
                Button(action: {
                    
                }) {
                    VStack {
                        if let lowProduct = lowProduct {
                            Text("Basic")
                            
                            Text(lowProduct.displayPrice)
                        }
                    }
                    .frame(width: buttonWidth, height: buttonHeight)
                }
                
                // Medium
                Button(action: {
                    
                }) {
                    VStack {
                        if let mediumProduct = mediumProduct {
                            Text("Advanced")
                            
                            Text(mediumProduct.displayPrice)
                        }
                    }
                    .frame(width: buttonWidth, height: buttonHeight)
                }
                
                // High
                Button(action: {
                    
                }) {
                    VStack {
                        if let highProduct = highProduct {
                            Text("Ultra")
                            
                            Text(highProduct.displayPrice)
                        }
                    }
                    .frame(width: buttonWidth, height: buttonHeight)
                }
            }
        }
    }
    
}

#Preview {
    
    UltraView()
        .environmentObject(ProductUpdater())
        .frame(width: 550.0, height: 500.0)
    
}
