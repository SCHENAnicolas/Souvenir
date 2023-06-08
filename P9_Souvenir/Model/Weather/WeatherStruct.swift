//
//  WeatherStruct.swift
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

// MARK: - Temperature
struct Temperature: Codable {
    let temp, tempMin, tempMax: Double
    
    enum CodingKeys: String, CodingKey {
        case temp
        case tempMin = "temp_min"
        case tempMax = "temp_max"
    }
}

// MARK: - Weather
struct Weather: Codable {
    let weatherDescription, icon: String
    
    enum CodingKeys: String, CodingKey {
        case weatherDescription = "description"
        case icon
    }
}

// MARK: - Location Object
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

// MARK: - Conforming Object
struct CoordinateInformation {
    let city: String
    let state: String
    let lat: Double
    let lon: Double
}

struct WeatherInformation {
    let temp: String
    let description: String
    let tempMin: String
    let tempMax: String
    let iconID: String
}
