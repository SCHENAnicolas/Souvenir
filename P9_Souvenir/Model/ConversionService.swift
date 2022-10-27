//
//  ConversionService.swift
//  P9_Souvenir
//
//  Created by Nicolas Schena on 21/09/2022.
//

import Foundation

class ConversionService {
    // MARK: - Pattern Singleton
    static var shared = ConversionService()
    private init() {}
    
    // MARK: - Properties
    private let apiKey = "wscyUz3t3BPNogLuE5AZE403Bn2lQcHm"
    private let conversionRateURL = URL(string: "https://api.apilayer.com/fixer/latest?base=EUR")!
    private let currencySymbolsURL = URL(string: "https://api.apilayer.com/fixer/symbols")!
    
    // MARK: - Function
    private func getConversionRate(callback: @escaping (Bool, CurrencyDateAndRate?) -> Void) {
        var request = URLRequest(url: conversionRateURL)
        request.httpMethod = "Get"
        request.addValue(apiKey, forHTTPHeaderField: "apikey")
        
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
                guard let rateJSON = try? JSONDecoder().decode(CurrencyDateAndRate.self, from: data) else {
                    callback(false, nil)
                    return
                }
                callback(true, rateJSON)
            }
        }
        task.resume()
    }
    
    private func getSymbols(callback: @escaping (Bool, CurrencyCodeAndName?) -> Void) {
        var request = URLRequest(url: currencySymbolsURL)
        request.httpMethod = "Get"
        request.addValue(apiKey, forHTTPHeaderField: "apikey")
        
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
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
        }
        task.resume()
    }
    
    private func createCurrencies(_ conversionCurrency: CurrencyCodeAndName, _ conversionRates: CurrencyDateAndRate) -> [Currency] {
        let currencies = conversionCurrency.symbols.compactMap({ (key: String, value: String) -> Currency? in
            let rates = conversionRates.rates
            let date = conversionRates.date
            guard let rate = rates[key] else { return nil }
            return Currency(date: date, rate: rate, name: value, code: key)
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
            self.getConversionRate { success, dateAndRates in
                guard let dateAndRates = dateAndRates, success == true else {
                    errorHandler()
                    return
                }
                let currencies = self.createCurrencies(symbols, dateAndRates)
                successCallback(currencies)
            }
        }
    }
}
