//
//  WeatherService.swift
//  P9_Souvenir
//
//  Created by Nicolas Schena on 27/10/2022.
//

import Foundation
import UIKit

class WeatherService {
    // MARK: - URLSession, Task
    private let session: URLSession
    private var task: URLSessionDataTask?
    
    init(session: URLSession = URLSession(configuration: .default)) {
        self.session = session
    }
    
    // MARK: - GeoCoordinate Service
    /// Function used to get location information from city
    func getGeoCoordinate(city: String, callback: @escaping (Result<CoordinateInformation, NetworkError>) -> Void) {
        let geoCoordinateURL = WeatherURL.openWeatherCityURL(city)
        
        task?.cancel()
        
        task = session.dataTask(with: geoCoordinateURL) { data, response, error in
            guard let data = data, error == nil else {
                callback(.failure(.noData))
                return
            }
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                callback(.failure(.invalidResponse))
                return
            }
            guard let coordinateJSON = try? JSONDecoder().decode(Coordinate.self, from: data) else {
                callback(.failure(.undecodableData))
                return
            }
            guard let coordinate = coordinateJSON.first else {
                callback(.failure(.emptyData))
                return
            }
            let conformCoordinate = self.conformCoordinate(coordinate)
            callback(.success(conformCoordinate))
        }
        task?.resume()
    }
    
    // MARK: - Weather service
    /// Function used to get weather information from location
    func getWeather(lat: Double, lon: Double, callback: @escaping (Result<WeatherInformation, NetworkError>) -> Void) {
        let weatherURL = WeatherURL.openWeatherCoordinateURL.weather.url(lat, lon)
        task?.cancel()
        
        task = session.dataTask(with: weatherURL) { data, response, error in
            guard let data = data, error == nil else {
                callback(.failure(.noData))
                return
            }
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                callback(.failure(.invalidResponse))
                return
            }
            guard let weatherJSON = try? JSONDecoder().decode(WeatherObject.self, from: data) else {
                callback(.failure(.undecodableData))
                return
            }
            let conformWeather = self.conformWeather(weatherJSON)
            callback(.success(conformWeather))
        }
        task?.resume()
    }
    
    // MARK: - GeoCity Service
    /// Function used to get city and state information from location
    func getGeoCity(lat: Double, lon: Double, callback: @escaping (Result<CoordinateInformation, NetworkError>) -> Void) {
        let geoCityCoordinateURL = WeatherURL.openWeatherCoordinateURL.geoCity.url(lat, lon)
        task?.cancel()
        
        task = session.dataTask(with: geoCityCoordinateURL) { data, response, error in
            guard let data = data, error == nil else {
                callback(.failure(.noData))
                return
            }
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                callback(.failure(.invalidResponse))
                return
            }
            guard let cityJSON = try? JSONDecoder().decode(Coordinate.self, from: data) else {
                callback(.failure(.undecodableData))
                return
            }
            guard let city = cityJSON.first else {
                callback(.failure(.emptyData))
                return
            }
            let conformCityNames = self.conformCoordinate(city)
            debugPrint(conformCityNames)
            callback(.success(conformCityNames))
        }
        task?.resume()
    }
    
    // MARK: - Conforming function
    /// Function facilitating the usage of data "Coordinate" in the Controller
    private func conformCoordinate(_ resultJSON: GeoCoordinate) -> CoordinateInformation {
        let conformCityNames = CoordinateInformation(city: "\(resultJSON.name)",
                                                     state: "\(resultJSON.state ?? "")",
                                                     lat: resultJSON.lat,
                                                     lon: resultJSON.lon)
        return conformCityNames
    }
    
    /// Function facilitating the usage of data "WeatherObject" in the Controller
    private func conformWeather(_ resultJSON: WeatherObject) -> WeatherInformation {
        let conformWeather = WeatherInformation(temp: "\(resultJSON.main.temp)°",
                                                description: resultJSON.weather[0].weatherDescription,
                                                tempMin: "\(resultJSON.main.tempMin)°",
                                                tempMax: "\(resultJSON.main.tempMax)°",
                                                iconID: "\(resultJSON.weather[0].icon)")
        return conformWeather
    }
}
