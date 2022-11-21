//
//  CurrenciesCode.swift
//  P9_Souvenir
//
//  Created by Nicolas Schena on 05/09/2022.
//

import Foundation

// MARK: - Symbols API Struct
struct CurrencyCodeAndName: Decodable {
    let symbols: [String: String]
}

struct Currency {
    let name: String
    let code: String
}

// MARK: - Conversion API Struct
struct CurrencyDateAndRate: Decodable {
    let info: Info
    let date: String
    let result: Double
}

struct Info: Codable {
    let rate: Double
}

// MARK: - Conversion used Struct
struct ConversionResult {
    let date: String
    let result: String
    let rate: String
}
