//
//  WeatherInformation.swift
//  P9_Souvenir
//
//  Created by Nicolas Schena on 27/10/2022.
//

import Foundation

// MARK: - Welcome
struct WeatherObject: Codable {
    let coord: GeoCoordinate
    let weather: [Weather]
    let main: Main
    let name: String
}

// MARK: - Coord
struct GeoCoordinate: Codable {
    let lon, lat: Double
}

// MARK: - Main
struct Main: Codable {
    let temp, feelsLike, tempMin, tempMax: Double
    let pressure, humidity: Int

    enum CodingKeys: String, CodingKey {
        case temp
        case feelsLike = "feels_like"
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case pressure, humidity
    }
}

// MARK: - Weather
struct Weather: Codable {
    let weatherDescription: String

    enum CodingKeys: String, CodingKey {
        case weatherDescription = "description"
    }
}
