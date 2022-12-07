//
//  TranslationService.swift
//  P9_Souvenir
//
//  Created by Nicolas Schena on 29/11/2022.
//

import Foundation

class TranslationService {

    private let session: URLSession
    private var task: URLSessionDataTask?

    init(session: URLSession = URLSession(configuration: .default)) {
        self.session = session
    }

    private let apiKey = "baca9ddc-bbc2-3880-444a-088d3483f94e:fx"

    func getTranstlation(text: String, callback: @escaping (Result<Translation, NetworkError>) -> Void) {
        var translationComponents = URLComponents(string: "https://api-free.deepl.com/v2/translate")
        let queryKey = URLQueryItem(name: "auth_key", value: apiKey)
        let queryText = URLQueryItem(name: "text", value: text)
        let querySource = URLQueryItem(name: "source_lang", value: "fr")
        let queryTarget = URLQueryItem(name: "target_lang", value: "en")

        translationComponents?.queryItems = [queryKey, queryText, querySource, queryTarget]
        guard let translationURL = translationComponents?.url else {
            return
        }
        var request = URLRequest(url: translationURL)
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
