//
//  SymbolsTestCase.swift
//  P9_SouvenirTests
//
//  Created by Nicolas Schena on 14/12/2022.
//

import XCTest
@testable import P9_Souvenir

class SymbolsTestCase: XCTestCase {
    func correctData(_ forRessource: String) -> Data {
        var  correctData: Data {
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
    func testGetSymbolsShouldFailedIfNoDataOrError() {
        URLProtocolStub.stub(data: .none,
                             response: .none,
                             error: NSError(domain: "an error", code: 0))
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)
        let sut = ConversionService(session: session)
        
        let expectation = expectation(description: "waiting ...")
        
        sut.getSymbols { result in
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
    func testGetSymbolsShouldFailedIfResponseCodeIsInvalid() {
        URLProtocolStub.stub(data: fakeData,
                             response: HTTPURLResponse(url: fakeURL!, statusCode: 500, httpVersion: .none, headerFields: .none),
                             error: .none)
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)
        let sut = ConversionService(session: session)
        
        let expectation = expectation(description: "waiting ...")
        
        sut.getSymbols { result in
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
    func testGetSymbolsShouldFailedIfIncorrectData() {
        URLProtocolStub.stub(data: fakeData,
                             response: HTTPURLResponse(url: fakeURL!, statusCode: 200, httpVersion: .none, headerFields: .none),
                             error: .none)
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)
        let sut = ConversionService(session: session)
        
        let expectation = expectation(description: "waiting ...")
        
        sut.getSymbols { result in
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
    func testGetSymbolsShouldSucceedIfCorrectData() {
        URLProtocolStub.stub(data: correctData("SymbolsData"),
                             response: HTTPURLResponse(url: fakeURL!, statusCode: 200, httpVersion: .none, headerFields: .none),
                             error: .none)
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)
        let sut = ConversionService(session: session)
        
        let expectation = expectation(description: "waiting ...")
        
        sut.getSymbols { result in
            guard case let .success(symbols) = result else {
                XCTFail(#function)
                return
            }
            XCTAssertEqual(symbols[0].code, "AFN")
            XCTAssertEqual(symbols[0].name, "Afghan Afghani")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
}
