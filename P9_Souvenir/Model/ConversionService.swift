//
//  ConversionService.swift
//  P9_Souvenir
//
//  Created by Nicolas Schena on 21/09/2022.
//

import Foundation

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
    private func getConversion(to: String, from: String, amount: Double, callback: @escaping (Bool, CurrencyDateAndRate?) -> Void) {
        let conversionURL = URL(string: "https://api.apilayer.com/fixer/convert?to=\(to)&from=\(from)&amount=\(amount)")!
        var request = URLRequest(url: conversionURL)
        request.httpMethod = "Get"
        request.addValue(apiKey, forHTTPHeaderField: "apikey")
        task?.cancel()
        
        task = session.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                callback(false, nil)
                return
            }
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                callback(false, nil)
                return
            }
            guard let conversionJSON = try? JSONDecoder().decode(CurrencyDateAndRate.self, from: data) else {
                callback(false, nil)
                return
            }
            callback(true, conversionJSON)
        }
        task?.resume()
    }
    
    private func getSymbols(callback: @escaping (Bool, CurrencyCodeAndName?) -> Void) {
        var request = URLRequest(url: currencySymbolsURL)
        request.httpMethod = "Get"
        request.addValue(apiKey, forHTTPHeaderField: "apikey")
        
        let task = session.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil,
                  let response = response as? HTTPURLResponse,
                  response.statusCode == 200 else {
                      callback(false, nil)
                      return
                  }
            guard let symbolsJSON = try? JSONDecoder().decode(CurrencyCodeAndName.self, from: data) else {
                callback(false, nil)
                return
            }
            callback(true, symbolsJSON)
        }
        task.resume()
    }
    
    // MARK: - Functions
    private func createSymbols(_ currenciesSymbol: CurrencyCodeAndName) -> [Currency] {
        let currencies = currenciesSymbol.symbols.compactMap({ (key: String, value: String) -> Currency? in
            return Currency(name: value, code: key)
        })
        let sortedCurrencies = currencies.sorted { $0.name < $1.name }
        return sortedCurrencies
    }
    
    func currencyAPICall(successCallback: @escaping ([Currency]) -> Void, errorHandler: @escaping () -> Void) {
        getSymbols { success, symbols in
            guard let symbols = symbols, success == true else {
                errorHandler()
                return
            }
            let currencies = self.createSymbols(symbols)
            successCallback(currencies)
        }
    }
    
    func conversionAPICall(_ to: String,_ from: String,_ amount: Double, callback: @escaping (Bool, ConversionResult) -> Void) {
        getConversion(to: to, from: from, amount: amount) { success, result in
            guard let date = result?.date,
                  let rate = result?.info.rate,
                  let result = result?.result else {
                      return
                  }
            guard let rate = String?(rate.description),
                  let result = String?(result.description) else {
                      return
                  }
            let conformConversion = ConversionResult(date: "Date: \n \(date)", result: " \(result)", rate: "Rate: \n \(rate)")
            callback(success, conformConversion)
        }
    }
}
