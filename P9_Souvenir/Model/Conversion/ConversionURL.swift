//
//  ConversionURL.swift
//  P9_Souvenir
//
//  Created by Nicolas Schena on 14/12/2022.
//

import Foundation

class ConversionURL {
    // MARK: - URL to get Symbols
    static func fixerSymbolsURL() -> URL {
        var components = URLComponents()
        let querryAppID = URLQueryItem(name: "apikey", value: APIConfig.fixerAPIKey)
        
        components.scheme = "https"
        components.host = "api.apilayer.com"
        components.path = "/fixer/symbols"
        components.queryItems = [querryAppID]
        
        return components.url!
    }
    
    // MARK: - URL to Convert
    static func fixerConversionURL(_ to: String, _ from: String, _ amount: Double) -> URL {
        var components = URLComponents()
        let queryAppID = URLQueryItem(name: "apikey", value: APIConfig.fixerAPIKey)
        let queryTo = URLQueryItem(name: "to", value: to)
        let queryFrom = URLQueryItem(name: "from", value: from)
        let queryAmount = URLQueryItem(name: "amount", value: "\(amount)")
        components.scheme = "https"
        components.host = "api.apilayer.com"
        components.path = "/fixer/convert"
        components.queryItems = [queryAppID, queryTo, queryFrom, queryAmount]
        
        return components.url!
    }
}
