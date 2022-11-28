//
//  ConversionService.swift
//  P9_Souvenir
//
//  Created by Nicolas Schena on 21/09/2022.
//

import Foundation

enum NetworkError: String, Error {
    case noData = "No Data available"
    case invalidResponse = "Wrong response code"
    case undecodableData = "Cannot decode Data"
    case unconformable = "Didn't succeeded to conform Data"
}

class ConversionService {
    
    private let session: URLSession
    private var task: URLSessionDataTask?
    
    init(session: URLSession = URLSession(configuration: .default)) {
        self.session = session
    }
    
    // MARK: - Properties
    private let apiKey = "wscyUz3t3BPNogLuE5AZE403Bn2lQcHm"
    private let currencySymbolsURL = URL(string: "https://api.apilayer.com/fixer/symbols")!
    
    // MARK: - API Call Functions
    private func getConversion(to: String, from: String, amount: Double, callback: @escaping (Result<CurrencyDateAndRate, NetworkError>) -> Void) {
        let conversionURL = URL(string: "https://api.apilayer.com/fixer/convert?to=\(to)&from=\(from)&amount=\(amount)")!
        var request = URLRequest(url: conversionURL)
        request.httpMethod = "Get"
        request.addValue(apiKey, forHTTPHeaderField: "apikey")
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
            guard let conversionJSON = try? JSONDecoder().decode(CurrencyDateAndRate.self, from: data) else {
                callback(.failure(.undecodableData))
                return
            }
            callback(.success(conversionJSON))
        }
        task?.resume()
    }
    
    private func getSymbols(callback: @escaping (Result<CurrencyCodeAndName, NetworkError>) -> Void) {
        var request = URLRequest(url: currencySymbolsURL)
        request.httpMethod = "Get"
        request.addValue(apiKey, forHTTPHeaderField: "apikey")
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
            guard let symbolsJSON = try? JSONDecoder().decode(CurrencyCodeAndName.self, from: data) else {
                callback(.failure(.undecodableData))
                return
            }
            callback(.success(symbolsJSON))
        }
        task.resume()
    }
    
    // MARK: - Functions
    private func createSymbolsArray(_ currenciesSymbol: CurrencyCodeAndName) -> [Currency] {
        let currencies = currenciesSymbol.symbols.compactMap({ (key: String, value: String) -> Currency? in
            return Currency(name: value, code: key)
        })
        let sortedCurrencies = currencies.sorted { $0.name < $1.name }
        return sortedCurrencies
    }
    
    func currencyAPICall(callback: @escaping (Result<[Currency], NetworkError>) -> Void) {
        getSymbols { currencies in
            switch currencies {
            case let .success(symbols):
                let conformCurrencies = self.createSymbolsArray(symbols)
                callback(.success(conformCurrencies))
            case .failure(_):
                callback(.failure(.unconformable))
            }
        }
    }
    
    func conversionAPICall(_ to: String,_ from: String,_ amount: Double, callback: @escaping (Result<ConversionResult, NetworkError>) -> Void) {
        getConversion(to: to, from: from, amount: amount) { conversion in
            switch conversion {
            case let .success(result):
                let conformConversion = ConversionResult(date: "Date: \n \(result.date)", result: " \(result.result)", rate: "Rate: \n \(result.info.rate)")
                callback(.success(conformConversion))
            case .failure(_):
                callback(.failure(.unconformable))
            }
        }
    }
}
