//
//  WeatherTestCase.swift
//  P9_SouvenirTests
//
//  Created by Nicolas Schena on 07/12/2022.
//

import XCTest
@testable import P9_Souvenir

class WeatherTestCase: XCTestCase {
    func correctData(_ forRessource: String) -> Data {
        var correctData: Data {
            let bundle = Bundle(for: TranslationTestCase.self)
            let url = bundle.url(forResource: forRessource, withExtension: "json")
            let data = try! Data(contentsOf: url!)
            return data
        }
        return correctData
    }
    let fakeURL = URL(string: "https://www.a-url.com")
    let fakeData = "a data".data(using: .utf8)
    
    //MARK: - Test Error or no Data
    func testGetWeatherShouldFailedIfNoDataOrError() {
        URLProtocolStub.stub(data: .none,
                             response: .none,
                             error: NSError(domain: "an error", code: 0))
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)
        let sut = WeatherService(session: session)
        
        let expectation = expectation(description: "waiting ...")
        
        sut.getWeather(lat: 0.0, lon: 0.0) { result in
            guard case let .failure(error) = result else {
                XCTFail(#function)
                return
            }
            XCTAssertEqual(error, .noData)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    //MARK: - Test code is Invalid
    func testGetWeatherShouldFailedIfResponseCodeIsInvalid() {
        URLProtocolStub.stub(data: fakeData,
                             response: HTTPURLResponse(url: fakeURL!, statusCode: 500, httpVersion: .none, headerFields: .none),
                             error: .none)
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)
        let sut = WeatherService(session: session)
        
        let expectation = expectation(description: "waiting ...")
        
        sut.getWeather(lat: 0.0, lon: 0.0) { result in
            guard case let .failure(error) = result else {
                XCTFail(#function)
                return
            }
            XCTAssertEqual(error, .invalidResponse)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    //MARK: - Test incorrect Data
    func testGetWeatherShouldFailedIfIncorrectData() {
        URLProtocolStub.stub(data: fakeData,
                             response: HTTPURLResponse(url: fakeURL!, statusCode: 200, httpVersion: .none, headerFields: .none),
                             error: .none)
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)
        let sut = WeatherService(session: session)
        
        let expectation = expectation(description: "waiting ...")
        
        sut.getWeather(lat: 0.0, lon: 0.0) { result in
            guard case let .failure(error) = result else {
                XCTFail(#function)
                return
            }
            XCTAssertEqual(error, .undecodableData)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    //MARK: - Test correct Data
    func testGetWeatherShouldSucceedIfCorrectData() {
        URLProtocolStub.stub(data: correctData("WeatherData"),
                             response: HTTPURLResponse(url: fakeURL!, statusCode: 200, httpVersion: .none, headerFields: .none),
                             error: .none)
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)
        let sut = WeatherService(session: session)
        
        let expectation = expectation(description: "waiting ...")
        
        sut.getWeather(lat: 0.0, lon: 0.0) { result in
            guard case let .success(cityWeather) = result else {
                XCTFail(#function)
                return
            }
            XCTAssertEqual(cityWeather.iconID, "01n")
            XCTAssertEqual(cityWeather.temp, "-2.75°")
            XCTAssertEqual(cityWeather.tempMax, "-1.12°")
            XCTAssertEqual(cityWeather.tempMin, "-4.53°")
            XCTAssertEqual(cityWeather.description, "ciel dégagé")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
}
