//
//  ConversionService.swift
//  P9_Souvenir
//
//  Created by Nicolas Schena on 21/09/2022.
//

import Foundation

class ConversionService {
    
    // MARK: - URLSession, Task
    private let session: URLSession
    private var task: URLSessionDataTask?
    
    init(session: URLSession = URLSession(configuration: .default)) {
        self.session = session
    }
    
    // MARK: - Conversion Service
    func getConversion(to: String, from: String, amount: Double, callback: @escaping (Result<ConversionResult, NetworkError>) -> Void) {
        let conversionURL = ConversionURL.fixerConversionURL(to, from, amount)
        
        task?.cancel()
        
        task = session.dataTask(with: conversionURL) { data, response, error in
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
            let conformConversion = self.conformConversion(conversionJSON)
            callback(.success(conformConversion))
        }
        task?.resume()
    }
    
    // MARK: - Symbols Service
    /// Function used to load all conversion Symbols, Name and Code of the country
    func getSymbols(callback: @escaping (Result<[Currency], NetworkError>) -> Void) {
        let symbolsURL = ConversionURL.fixerSymbolsURL()
        
        task?.cancel()
        
        let task = session.dataTask(with: symbolsURL) { data, response, error in
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
            let conformCurrencies = self.createSymbolsArray(symbolsJSON)
            callback(.success(conformCurrencies))
        }
        task.resume()
    }
    
    // MARK: - Conforming function
    /// Function used to transform the dictionnary of symbols into an array of "Currency" and reorder alphabetically
    private func createSymbolsArray(_ currenciesSymbol: CurrencyCodeAndName) -> [Currency] {
        let currencies = currenciesSymbol.symbols.compactMap({ (key: String, value: String) -> Currency? in
            return Currency(name: value, code: key)
        })
        let sortedCurrencies = currencies.sorted { $0.name < $1.name }
        return sortedCurrencies
    }
    
    /// Function facilitating the usage of data "CurrencyDateAndRate" in the Controller
    private func conformConversion(_ result: CurrencyDateAndRate) -> ConversionResult {
        let conformConversion = ConversionResult(date: "Date: \n \(result.date)",
                                                 result: " \(result.result)",
                                                 rate: "Rate: \n \(result.info.rate)")
        return conformConversion
    }
}
