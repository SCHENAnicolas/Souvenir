//
//  ConversionTestCase.swift
//  P9_SouvenirTests
//
//  Created by Nicolas Schena on 07/12/2022.
//

import XCTest
@testable import P9_Souvenir

class ConversionTestCase: XCTestCase {
    func correctData(_ forRessource: String) -> Data {
        var correctData: Data {
            let bundle = Bundle(for: ConversionTestCase.self)
            let url = bundle.url(forResource: forRessource, withExtension: "json")
            let data = try! Data(contentsOf: url!)
            return data
        }
        return correctData
    }
    let fakeURL = URL(string: "https://www.a-url.com")
    let fakeData = "a data".data(using: .utf8)
    
    //MARK: - Test Error or no Data
    func testGetConversionShouldFailedIfNoDataOrError() {
        URLProtocolStub.stub(data: .none,
                             response: .none,
                             error: NSError(domain: "an error", code: 0))
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)
        let sut = ConversionService(session: session)
        
        let expectation = expectation(description: "waiting ...")
        
        sut.getConversion(to: "", from: "", amount: 0.0) { result in
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
    func testGetConversionShouldFailedIfResponseCodeIsInvalid() {
        URLProtocolStub.stub(data: fakeData,
                             response: HTTPURLResponse(url: fakeURL!, statusCode: 500, httpVersion: .none, headerFields: .none),
                             error: .none)
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)
        let sut = ConversionService(session: session)
        
        let expectation = expectation(description: "waiting ...")
        
        sut.getConversion(to: "", from: "", amount: 0.0) { result in
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
    func testGetConversionShouldFailedIfIncorrectData() {
        URLProtocolStub.stub(data: fakeData,
                             response: HTTPURLResponse(url: fakeURL!, statusCode: 200, httpVersion: .none, headerFields: .none),
                             error: .none)
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)
        let sut = ConversionService(session: session)
        
        let expectation = expectation(description: "waiting ...")
        
        sut.getConversion(to: "", from: "", amount: 0.0) { result in
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
    func testGetConversionShouldSucceedIfCorrectData() {
        URLProtocolStub.stub(data: correctData("ConversionData"),
                             response: HTTPURLResponse(url: fakeURL!, statusCode: 200, httpVersion: .none, headerFields: .none),
                             error: .none)
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)
        let sut = ConversionService(session: session)
        
        let expectation = expectation(description: "waiting ...")
        
        sut.getConversion(to: "", from: "", amount: 0.0) { result in
            guard case let .success(conversion) = result else {
                XCTFail(#function)
                return
            }
            XCTAssertEqual(conversion.result, " 1055.365")
            XCTAssertEqual(conversion.date, "Date: \n 2022-12-13")
            XCTAssertEqual(conversion.rate, "Rate: \n 1.055365")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
}
