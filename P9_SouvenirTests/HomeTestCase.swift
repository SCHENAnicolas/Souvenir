//
//  HomeTestCase.swift
//  P9_SouvenirTests
//
//  Created by Nicolas Schena on 08/12/2022.
//

import XCTest
@testable import P9_Souvenir

class HomeTestCase: XCTestCase {
    let fakeURL = URL(string: "https://www.a-url.com")
    let fakeData = "image".data(using: .utf8)
    
    //MARK: - Test Error or no Data
    func testGetImageShouldFailedIfNoDataOrError() {
        URLProtocolStub.stub(data: .none,
                             response: .none,
                             error: NSError(domain: "an error", code: 0))
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)
        let sut = HomeService(session: session)
        
        let expectation = expectation(description: "waiting ...")
        
        sut.getImage { result in
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
    func testGetImageShouldFailedIfResponseCodeIsInvalid() {
        URLProtocolStub.stub(data: fakeData,
                             response: HTTPURLResponse(url: fakeURL!, statusCode: 500, httpVersion: .none, headerFields: .none),
                             error: .none)
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)
        let sut = HomeService(session: session)
        
        let expectation = expectation(description: "waiting ...")
        
        sut.getImage { result in
            guard case let .failure(error) = result else {
                XCTFail(#function)
                return
            }
            XCTAssertEqual(error, .invalidResponse)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    //MARK: - Test correct Data
    func testGetImageShouldSucceedIfCorrectData() {
        let imageData = "image".data(using: .utf8)
        URLProtocolStub.stub(data: fakeData,
                             response: HTTPURLResponse(url: fakeURL!, statusCode: 200, httpVersion: .none, headerFields: .none),
                             error: .none)
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)
        let sut = HomeService(session: session)
        
        let expectation = expectation(description: "waiting ...")
        
        sut.getImage { result in
            guard case let .success(image) = result else {
                XCTFail(#function)
                return
            }
            XCTAssertEqual(image, imageData)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
}
