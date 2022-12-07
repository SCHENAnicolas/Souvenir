//
//  WeatherService.swift
//  P9_Souvenir
//
//  Created by Nicolas Schena on 27/10/2022.
//

import Foundation
import UIKit

class WeatherService {

    private let session: URLSession
    private var task: URLSessionDataTask?

    init(session: URLSession = URLSession(configuration: .default)) {
        self.session = session
    }

    // MARK: - Properties
    private let apikey = "30160e6d0987743d441178ae590138ca"

    // MARK: - Function    
    private func getGeoCoordinate(city: String, callback: @escaping (Result<Coordinate, NetworkError>) -> Void) {
        var geoCoordinateComponents = URLComponents(string: "https://api.openweathermap.org/geo/1.0/direct?")
        let queryAppID = URLQueryItem(name: "appid", value: apikey)
        let queryCity = URLQueryItem(name: "q", value: city)

        geoCoordinateComponents?.queryItems = [queryAppID, queryCity]
        guard let geoCoordinateURL = geoCoordinateComponents?.url else {
            return
        }
        var request = URLRequest(url: geoCoordinateURL)
        request.httpMethod = "Get"
        task?.cancel()

        task = session.dataTask(with: request) { data, response, error in
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
            callback(.success(coordinateJSON))
        }
        task?.resume()
    }

    private func getWeather(lat: Double, lon: Double, callback: @escaping (Result<WeatherObject, NetworkError>) -> Void) {
        let weatherURL = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&lang=fr&appid=\(apikey)&units=metric")!
        var request = URLRequest(url: weatherURL)
        request.httpMethod = "Get"
        task?.cancel()

        task = session.dataTask(with: request) { data, response, error in
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
            callback(.success(weatherJSON))
        }
        task?.resume()
    }

    private func getGeoCity(lat: Double, lon: Double, callback: @escaping (Result<Coordinate, NetworkError>) -> Void) {
        let reverseGeoCoordinateURL = URL(string:"https://api.openweathermap.org/geo/1.0/reverse?lat=\(lat)&lon=\(lon)&appid=\(apikey)")!
        var request = URLRequest(url: reverseGeoCoordinateURL)
        request.httpMethod = "Get"
        task?.cancel()

        task = session.dataTask(with: request) { data, response, error in
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
            callback(.success(cityJSON))
        }
        task?.resume()
    }

    func cityAndStateNames(lat: Double, lon: Double, callback: @escaping (Result<CoordinateInformation, NetworkError>) -> Void) {
        getGeoCity(lat: lat, lon: lon) { cityNames in
            switch cityNames {
            case let .success(result):
                let conformCityNames = CoordinateInformation(city: "\(result[0].name)",
                                                             state: "\(result[0].state ?? "")",
                                                             lat: result[0].lat,
                                                             lon: result[0].lon)
                callback(.success(conformCityNames))
            case .failure(_):
                callback(.failure(.unconformable))
            }

        }
    }

    func geoCoordinate(city: String, callback: @escaping (Result<CoordinateInformation, NetworkError>) -> Void) {
        getGeoCoordinate(city: city) { coordinate in
            switch coordinate {
            case let .success(result):
                let conformCoordinate = CoordinateInformation(city: "\(result[0].name)",
                                                              state: "\(result[0].state ?? "")",
                                                              lat: result[0].lat,
                                                              lon: result[0].lon)
                callback(.success(conformCoordinate))
            case .failure(_):
                callback(.failure(.unconformable))
            }
        }
    }

    func geoWeather(lat: Double, lon: Double, callback: @escaping (Result<WeatherInformation, NetworkError>) -> Void) {
        getWeather(lat: lat, lon: lon) { weather in
            switch weather {
            case let .success(result):
                let conformWeather = WeatherInformation(temp: "\(result.main.temp)°",
                                                        description: result.weather[0].weatherDescription,
                                                        tempMin: "\(result.main.tempMin)°",
                                                        tempMax: "\(result.main.tempMax)°",
                                                        iconID: "\(result.weather[0].icon)")
                callback(.success(conformWeather))
            case .failure(_):
                callback(.failure(.unconformable))
            }
        }
    }
}
