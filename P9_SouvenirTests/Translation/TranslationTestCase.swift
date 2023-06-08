//
//  TranslationTestCase.swift
//  P9_SouvenirTests
//
//  Created by Nicolas Schena on 05/12/2022.
//

import XCTest
@testable import P9_Souvenir

class TranslationTestCase: XCTestCase {
    var correctData: Data {
        let bundle = Bundle(for: TranslationTestCase.self)
        let url = bundle.url(forResource: "TranslationData", withExtension: "json")
        let data = try! Data(contentsOf: url!)
        return data
    }
    let fakeURL = URL(string: "https://www.a-url.com")
    let fakeData = "a data".data(using: .utf8)
    
    //MARK: - Test Error or no Data
    func testGetTranslationShouldFailedIfNoDataOrError() {
        URLProtocolStub.stub(data: .none,
                             response: .none,
                             error: NSError(domain: "an error", code: 0))
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)
        let sut = TranslationService(session: session)
        
        let expectation = expectation(description: "waiting ...")
        
        sut.getTranstlation(text: "") { result in
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
    func testGetTranslationShouldFailedIfResponseCodeIsInvalid() {
        URLProtocolStub.stub(data: fakeData,
                             response: HTTPURLResponse(url: fakeURL!, statusCode: 500, httpVersion: .none, headerFields: .none),
                             error: .none)
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)
        let sut = TranslationService(session: session)
        
        let expectation = expectation(description: "waiting ...")
        
        sut.getTranstlation(text: "") { result in
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
    func testGetTranslationShouldFailedIfIncorrectData() {
        URLProtocolStub.stub(data: fakeData, response: HTTPURLResponse(url: fakeURL!, statusCode: 200, httpVersion: .none, headerFields: .none), error: .none)
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)
        let sut = TranslationService(session: session)
        
        let expectation = expectation(description: "waiting ...")
        
        sut.getTranstlation(text: "") { result in
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
    func testGetTranslationShouldSucceedIfCorrectData() {
        URLProtocolStub.stub(data: correctData, response: HTTPURLResponse(url: fakeURL!, statusCode: 200, httpVersion: .none, headerFields: .none), error: .none)
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)
        let sut = TranslationService(session: session)
        
        let expectation = expectation(description: "waiting ...")
        
        sut.getTranstlation(text: "") { result in
            guard case let .success(translatedText) = result else {
                XCTFail(#function)
                return
            }
            XCTAssertEqual(translatedText.translations[0].text, "Hello world")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
}
