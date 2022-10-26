//
//  CurrenciesCode.swift
//  P9_Souvenir
//
//  Created by Nicolas Schena on 05/09/2022.
//

import Foundation

struct CurrencyCodeAndName: Codable {
    let symbols: [String: String]
}

struct CurrencyDateAndRate: Codable {
    let rates: [String: Double]
    let date: String
}

struct Currency {
    let date: String
    let rate: Double
    let name: String
    let code: String
}
