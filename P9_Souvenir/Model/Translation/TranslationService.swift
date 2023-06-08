//
//  TranslationService.swift
//  P9_Souvenir
//
//  Created by Nicolas Schena on 29/11/2022.
//

import Foundation

class TranslationService {
    
    // MARK: - URLSession, Task
    private let session: URLSession
    private var task: URLSessionDataTask?
    
    init(session: URLSession = URLSession(configuration: .default)) {
        self.session = session
    }
    
    // MARK: - Translation's API URL
    private func deeplURL(text: String) -> URL {
        var components = URLComponents()
        let queryAppID = URLQueryItem(name: "auth_key", value: APIConfig.deeplAPIKey)
        let queryText = URLQueryItem(name: "text", value: text)
        let querySource = URLQueryItem(name: "source_lang", value: "fr")
        let queryTarget = URLQueryItem(name: "target_lang", value: "en")
        
        components.scheme = "https"
        components.host = "api-free.deepl.com"
        components.path = "/v2/translate"
        components.queryItems = [queryAppID, queryText, querySource, queryTarget]
        
        return components.url!
    }
    
    
    // MARK: - Translation Service
    /// Function used to post text to the API and get the translation
    func getTranstlation(text: String, callback: @escaping (Result<Translation, NetworkError>) -> Void) {
        let url = deeplURL(text: text)
        
        var request = URLRequest(url: url)
        request.httpMethod = "Post"
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
            guard let translatedTextJSON = try? JSONDecoder().decode(Translation.self, from: data) else {
                callback(.failure(.undecodableData))
                return
            }
            callback(.success(translatedTextJSON))
        }
        task?.resume()
    }
}
