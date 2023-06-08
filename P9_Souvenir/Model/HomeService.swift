//
//  HomeService.swift
//  P9_Souvenir
//
//  Created by Nicolas Schena on 23/08/2022.
//

import Foundation

// MARK: - Error case
enum NetworkError: String, Error {
    case noData = "No Data available"
    case invalidResponse = "Wrong response code"
    case undecodableData = "Cannot decode Data"
    case unconformable = "Didn't succeeded to conform Data"
    case emptyData = "The array is empty"
}

class HomeService {
    
    // MARK: - URLSession, Task
    private let session: URLSession
    private var task: URLSessionDataTask?
    
    init(session: URLSession = URLSession(configuration: .default)) {
        self.session = session
    }
    
    let cheers = ["Une nouvelle journée commence",
                  "Bon courage pour la journée",
                  "C'est l'heure du café, ou allons nous ?",
                  "Fait-il beau ce matin ? Regardons ça ensemble",
                  "Une nouvelle journée commence, let's go !"
    ]
    
    // MARK: - Picture's API URL
    private func pictureURL() -> URL {
        var components = URLComponents()
        let queryWidth = URLQueryItem(name: "width", value: "400")
        let queryHeight = URLQueryItem(name: "height", value: "400")
        let queryCategory = URLQueryItem(name: "category", value: "nature")
        
        components.scheme = "https"
        components.host = "api.api-ninjas.com"
        components.path = "/v1/randomimage"
        components.queryItems = [queryWidth, queryHeight, queryCategory]
        
        return components.url!
    }
    
    // MARK: - Image Service
    /// Function getting a random picture for HomeView
    func getImage(callback: @escaping (Result<Data, NetworkError>) -> Void) {
        var request = URLRequest(url: pictureURL())
        request.httpMethod = "Get"
        request.setValue(APIConfig.ninjasAPIKey, forHTTPHeaderField: "X-Api-Key")
        task?.cancel()
        
        let task = session.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                callback(.failure(.noData))
                return
            }
            guard let response = response as? HTTPURLResponse,
                  response.statusCode == 200 else {
                      callback(.failure(.invalidResponse))
                      return
                  }
            guard let imageData = Data(base64Encoded: data, options: .ignoreUnknownCharacters) else {
                print(data)
                callback(.failure(.undecodableData))
                return
            }
            callback(.success(imageData))
        }
        task.resume()
    }
}
