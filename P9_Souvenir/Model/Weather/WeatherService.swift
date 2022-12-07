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
    private let appid = "30160e6d0987743d441178ae590138ca"
    
    // MARK: - Function
    private func geoCoordinate(city: String) {
        
    }
    
    func getGeoCoordinate(city: String, callback: @escaping (Result<Coordinate, NetworkError>) -> Void) {
        var geoComponents = URLComponents(string: "https://api.openweathermap.org/geo/1.0/direct?")
        let queryAppID = URLQueryItem(name: "appid", value: appid)
        let queryCity = URLQueryItem(name: "q", value: city)
        
        geoComponents?.queryItems = [queryAppID, queryCity]
        guard let geoCodingURL = geoComponents?.url else {
            return
        }
        var request = URLRequest(url: geoCodingURL)
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
    
    func getWeather(lat: Double, lon: Double, callback: @escaping (Result<WeatherObject, NetworkError>) -> Void) {
        let weatherURL = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&lang=fr&appid=\(appid)&units=metric")!
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
}
