//
//  WeatherURL.swift
//  P9_Souvenir
//
//  Created by Nicolas Schena on 14/12/2022.
//

import Foundation

class WeatherURL {
    // MARK: - URL from location
    enum openWeatherCoordinateURL {
        case geoCity
        case weather
        
        /// Function used to light two of the APICall's function which use latitude and longitude parameter
        func url(_ lat: Double, _ lon: Double) -> URL {
            var components = URLComponents()
            components.scheme = "https"
            components.host = "api.openweathermap.org"
            let queryAppID = URLQueryItem(name: "appid", value: APIConfig.openWeatherAPIKey)
            let queryLat = URLQueryItem(name: "lat", value: "\(lat)")
            let queryLon = URLQueryItem(name: "lon", value: "\(lon)")
            
            switch self {
            case .weather:
                components.path = "/data/2.5/weather"
                let queryUnits = URLQueryItem(name: "units", value: "metric")
                components.queryItems = [queryAppID, queryLat, queryLon, queryUnits]
            case .geoCity:
                components.path = "/geo/1.0/reverse"
                components.queryItems = [queryAppID, queryLat, queryLon]
            }
            return components.url!
        }
    }
    
    // MARK: - URL from city
    static func openWeatherCityURL(_ city: String) -> URL {
        var components = URLComponents()
        let queryAppID = URLQueryItem(name: "appid", value: APIConfig.openWeatherAPIKey)
        let queryCity = URLQueryItem(name: "q", value: city)
        
        components.scheme = "https"
        components.host = "api.openweathermap.org"
        components.path = "/geo/1.0/direct"
        components.queryItems = [queryAppID, queryCity]
        
        return components.url!
    }
}
