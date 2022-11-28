//
//  WeatherInformation.swift
//  P9_Souvenir
//
//  Created by Nicolas Schena on 27/10/2022.
//

import Foundation


// MARK: - Weather Object
struct WeatherObject: Codable {
    let weather: [Weather]
    let main: Temperature
    let name: String
}

// MARK: - Temperature decoding
struct Temperature: Codable {
    let temp, tempMin, tempMax: Double

    enum CodingKeys: String, CodingKey {
        case temp
        case tempMin = "temp_min"
        case tempMax = "temp_max"
    }
}

// MARK: - Weather decoding
struct Weather: Codable {
    let weatherDescription, icon: String

    enum CodingKeys: String, CodingKey {
        case weatherDescription = "description"
        case icon
    }
}

// MARK: - Coordinate decoding
struct GeoCoordinate: Codable {
    let name: String
    let lat, lon: Double
    let state: String?

    enum CodingKeys: String, CodingKey {
        case name
        case lat, lon, state
    }
}
typealias Coordinate = [GeoCoordinate]
