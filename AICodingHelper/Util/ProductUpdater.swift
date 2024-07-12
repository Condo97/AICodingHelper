import Foundation
import StoreKit
import SwiftUI

class ProductUpdater: ObservableObject {
    
    @Published var shouldRetryLoadingOnError: Bool = false
    @Published var subscriptionActive: Bool = false
    
    @Published var weeklyLowProduct: Product?
    @Published var weeklyMediumProduct: Product?
    @Published var weeklyHighProduct: Product?
    @Published var monthlyLowProduct: Product?
    @Published var monthlyMediumProduct: Product?
    @Published var monthlyHighProduct: Product?
    
    
    init() {
        Task {
            await refresh()
        }
    }
    
    func refresh() async {
        let weeklyLowProductID = UserDefaultsHelper.weeklyLowProductID
        let weeklyMediumProductID = UserDefaultsHelper.weeklyMediumProductID
        let weeklyHighProductID = UserDefaultsHelper.weeklyHighProductID
        let monthlyLowProductID = UserDefaultsHelper.monthlyLowProductID
        let monthlyMediumProductID = UserDefaultsHelper.monthlyMediumProductID
        let monthlyHighProductID = UserDefaultsHelper.monthlyHighProductID
        
        do {
            let products = try await IAPManager.fetchProducts(productIDs: [
                weeklyLowProductID,
                weeklyMediumProductID,
                weeklyHighProductID,
                monthlyLowProductID,
                monthlyMediumProductID,
                monthlyHighProductID
            ])
            
            await MainActor.run {
                self.weeklyLowProduct = products.first(where: {$0.id == weeklyLowProductID})
                self.weeklyMediumProduct = products.first(where: {$0.id == weeklyMediumProductID})
                self.weeklyHighProduct = products.first(where: {$0.id == weeklyHighProductID})
                self.monthlyLowProduct = products.first(where: {$0.id == monthlyLowProductID})
                self.monthlyMediumProduct = products.first(where: {$0.id == monthlyMediumProductID})
                self.monthlyHighProduct = products.first(where: {$0.id == monthlyHighProductID})
                print(weeklyLowProductID)
            }
        } catch {
            // TODO: Handle errors
            print("Error fetching products in UltraViewModel... \(error)")
        }
    }
    
}
