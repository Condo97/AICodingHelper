import Foundation


struct GetImportantConstantsResponse: Codable {
    
    struct Body: Codable {
        
        var sharedSecret: String?
        
        var weeklyLowProductID: String?
        var monthlyLowProductID: String?
        var weeklyMediumProductID: String?
        var monthlyMediumProductID: String?
        var weeklyHighProductID: String?
        var monthlyHighProductID: String?
        
        var weeklyLowTokens: Int?
        var weeklyMediumTokens: Int?
        var weeklyHighTokens: Int?
        var monthlyLowTokens: Int?
        var monthlyMediumTokens: Int?
        var monthlyHighTokens: Int?
        
        var shareURL: String
        var freeEssayCap: Int
        
        enum CodingKeys: String, CodingKey {
            case sharedSecret
            case weeklyLowProductID
            case monthlyLowProductID
            case weeklyMediumProductID
            case monthlyMediumProductID
            case weeklyHighProductID
            case monthlyHighProductID
            case weeklyLowTokens
            case weeklyMediumTokens
            case weeklyHighTokens
            case monthlyLowTokens
            case monthlyMediumTokens
            case monthlyHighTokens
            case shareURL
            case freeEssayCap
        }
        
    }
    
    var body: Body
    var success: Int
    
    enum CodingKeys: String, CodingKey {
        case body = "Body"
        case success = "Success"
    }
    
}
