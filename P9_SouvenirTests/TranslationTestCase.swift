//
//  TranslationTestCase.swift
//  P9_SouvenirTests
//
//  Created by Nicolas Schena on 05/12/2022.
//

import XCTest
@testable import P9_Souvenir

class TranslationTestCase: XCTestCase {
    
    
    
    func testFetchingDataSuccessfully() {
        URLProtocolStub.stub(data: .none, response: .none, error: NSError(domain: "an error", code: 0))
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
    
    func testFetchingData() {
        URLProtocolStub.stub(data: "a data".data(using: .utf8), response: HTTPURLResponse(url: URL(string: "https://www.a-url.com")!, statusCode: 500, httpVersion: .none, headerFields: .none), error: .none)
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
    
    func testFetchingDatadddd() {
        URLProtocolStub.stub(data: "a data".data(using: .utf8), response: HTTPURLResponse(url: URL(string: "https://www.a-url.com")!, statusCode: 200, httpVersion: .none, headerFields: .none), error: .none)
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
    
    func testFetchingDvheaojvno() {
        let text = "Hello world"
        let translationElements = TranslationElement(text: text)
        let translation = Translation.init(translations: [translationElements])
        let textJSON = try? JSONEncoder().encode(translation)
        
        let dataJSON = textJSON!
        
        
        URLProtocolStub.stub(data: dataJSON, response: HTTPURLResponse(url: URL(string: "https://www.a-url.com")!, statusCode: 200, httpVersion: .none, headerFields: .none), error: .none)
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)
        let sut = TranslationService(session: session)
        
        let expectation = expectation(description: "waiting ...")
        
        sut.getTranstlation(text: "Hello") { result in
            guard case let .success(translatedText) = result else {
                XCTFail(#function)
                return
            }
            XCTAssertNotNil(translatedText)
            expectation.fulfill()
        }
    
        wait(for: [expectation], timeout: 0.1)
    }
    
}

// MARK: - Stub Protocol
class URLProtocolStub: URLProtocol {
    private struct Stub {
        let data: Data?
        let response: URLResponse?
        let error: Error?
    }

    private static var _stub: Stub?
    private static var stub: Stub? {
        get { return queue.sync { _stub } }
        set { queue.sync { _stub = newValue } }
    }

    private static let queue = DispatchQueue(label: "URLProtocolStub.queue")

    static func stub(data: Data?, response: URLResponse?, error: Error?) {
        stub = Stub(data: data, response: response, error: error)
    }

    static func removeStub() {
        stub = nil
    }

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        guard let stub = URLProtocolStub.stub else { return }

        if let data = stub.data {
            client?.urlProtocol(self, didLoad: data)
        }

        if let response = stub.response {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }

        if let error = stub.error {
            client?.urlProtocol(self, didFailWithError: error)
        } else {
            client?.urlProtocolDidFinishLoading(self)
        }
    }

    override func stopLoading() {}
}
