//
//  WeatherService.swift
//  P9_Souvenir
//
//  Created by Nicolas Schena on 27/10/2022.
//

import Foundation

class WeatherService {
    // MARK: - Pattern Singleton
    static var shared = WeatherService()
    private init() {}
    
    // MARK: - Properties
    private let appid = "30160e6d0987743d441178ae590138ca"
    
    // MARK: - Function
    func getGeoCoordinate(city: String, callback: @escaping (Bool, GeoCoordinate?) -> Void) {
        let geoCodingURL = URL(string: "https://api.openweathermap.org/geo/1.0/direct?q=\(city)&appid=\(appid)")!
        var request = URLRequest(url: geoCodingURL)
        request.httpMethod = "Get"
        
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                guard let data = data, error == nil else {
                    callback(false, nil)
                    return
                }
                guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                    callback(false, nil)
                    return
                }
                guard let coordinateJSON = try? JSONDecoder().decode([GeoCoordinate].self, from: data) else {
                    callback(false, nil)
                    return
                }
                callback(true, coordinateJSON.first)
            }
        }
        task.resume()
    }
    
    func getWeather(lat: Double, lon: Double, callback: @escaping (Bool, WeatherObject?) -> Void) {
        let weatherURL = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&lang=fr&appid=\(appid)&units=metric")!
        var request = URLRequest(url: weatherURL)
        request.httpMethod = "Get"
        
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                guard let data = data, error == nil else {
                    callback(false, nil)
                    return
                }
                guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                    callback(false, nil)
                    return
                }
                guard let weatherJSON = try? JSONDecoder().decode(WeatherObject.self, from: data) else {
                    callback(false, nil)
                    return
                }
                callback(true, weatherJSON)
            }
        }
        task.resume()
    }
}
