import Foundation

class ConstantsHelper {
    
    static func updateImportantConstants() async throws {
        let response = try await AICodingHelperHTTPSConnector().getImportantConstants()
        
        guard response.success == 1 else {
            // Handle the error case, possibly by setting default values
            setIfNil(Constants.Additional.defaultShareURL, forKey: Constants.UserDefaults.shareURL)
//            setIfNil(Constants.Interfaces.defaultFreeEssayCap, forKey: Constants.UserDefaults.freeEssayCap)
            return
        }
        
        // Update constants
        UserDefaultsHelper.weeklyLowProductID = response.body.weeklyLowProductID ?? Constants.IAP.defaultWeeklyLowProductID
        UserDefaultsHelper.monthlyLowProductID = response.body.monthlyLowProductID ?? Constants.IAP.defaultMonthlyLowProductID
        UserDefaultsHelper.weeklyMediumProductID = response.body.weeklyMediumProductID ?? Constants.IAP.defaultWeeklyMediumProductID
        UserDefaultsHelper.monthlyMediumProductID = response.body.monthlyMediumProductID ?? Constants.IAP.defaultMonthlyMediumProductID
        UserDefaultsHelper.weeklyHighProductID = response.body.weeklyHighProductID ?? Constants.IAP.defaultWeeklyHighProductID
        UserDefaultsHelper.monthlyHighProductID = response.body.monthlyHighProductID ?? Constants.IAP.defaultMonthlyHighProductID
        UserDefaultsHelper.weeklyLowTokenLimit = response.body.weeklyLowTokens ?? Constants.IAP.defaultWeeklyLowTokenLimit
        UserDefaultsHelper.weeklyMediumTokenLimit = response.body.weeklyMediumTokens ?? Constants.IAP.defaultWeeklyMediumTokenLimit
        UserDefaultsHelper.weeklyHighTokenLimit = response.body.weeklyHighTokens ?? Constants.IAP.defaultWeeklyHighTokenLimit
        UserDefaultsHelper.monthlyLowTokenLimit = response.body.monthlyLowTokens ?? Constants.IAP.defaultMonthlyLowTokenLimit
        UserDefaultsHelper.monthlyMediumTokenLimit = response.body.monthlyMediumTokens ?? Constants.IAP.defaultMonthlyMediumTokenLimit
        UserDefaultsHelper.monthlyHighTokenLimit = response.body.monthlyHighTokens ?? Constants.IAP.defaultMonthlyHighTokenLimit
        UserDefaultsHelper.shareURL = response.body.shareURL
//        UserDefaultsHelper.freeEssayCap = response.body.freeEssayCap
    }
    
    private static func setIfNil(_ value: Any, forKey key: String) {
        if UserDefaults.standard.object(forKey: key) == nil {
            UserDefaults.standard.set(value, forKey: key)
        }
    }
    
}
