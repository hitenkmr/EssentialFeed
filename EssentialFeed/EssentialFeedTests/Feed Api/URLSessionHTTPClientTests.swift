//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Hitender Kumar on 18/02/21.
//

import Foundation
import XCTest
@testable import EssentialFeed

class URLSessionHTTPClient {
    private let session : URLSession
    
    init(session : URLSession = .shared) {
        self.session = session
    }
    
    func get(from url : URL, completion : @escaping (HTTPClientResult) -> Void) {
        self.session.dataTask(with: url, completionHandler: { data, response, error in
            if let error = error {
                completion(.failure(error))
            }
        }).resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        URLProtocolStub.startInterceptingUrlRequests()
    }
    
    override func tearDown() {
        super.tearDown()
        URLProtocolStub.stopInterceptingUrlRequests()
    }
    
    func test_getFromURL_PerformsGetRequesWithURL() {
        let exp = expectation(description: "wait for request")
        let url = URL(string: "http://any-url.com")!
        URLProtocolStub.observeRequests { (request) in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        makeSUT().get(from: url, completion: { _ in })
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_getFromURL_failsOnRequestError() {
        let url = URL(string: "http://any-url.com")!
        let error = NSError(domain: "error completion call", code: 1)
        
        URLProtocolStub.stub(error: error)
 
        let exp = expectation(description: "wait for compeltion")
        
        makeSUT().get(from: url) { result in
            switch result {
            case let .failure(receivedError as NSError):
                XCTAssertEqual(receivedError.domain, error.domain)
                XCTAssertEqual(receivedError.code, error.code)
            default:
                XCTFail("Expected failure with error \(error), got result \(result)")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    //MARK: HELPERS
    
    private func makeSUT(line : UInt = #line, file : StaticString = #file) -> URLSessionHTTPClient {
        let sut = URLSessionHTTPClient()
        trackForMemoryLeaks(instance: sut, file : file, line :line)
        return sut
    }
}

//MARK: HELPERS

private class URLProtocolStub: URLProtocol {
    
    private static var stub : Stub?
    private static var requestObserver : ((URLRequest) -> Void)?
    
    private struct Stub {
        let error : Error?
    }
    
    static func stub(error : Error? = nil) {
        stub = .init(error: error)
    }
    
    func some() {
        URLProtocolStub.requestObserver = nil
    }
    
    static func observeRequests(observer : @escaping (URLRequest) -> Void) {
        requestObserver = observer
    }
    
    static func startInterceptingUrlRequests() {
        URLProtocolStub.registerClass(URLProtocolStub.self)
    }
    
    static func stopInterceptingUrlRequests() {
        URLProtocolStub.unregisterClass(URLProtocolStub.self)
        stub = nil
        requestObserver = nil
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
        requestObserver?(request)
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        guard let stub = URLProtocolStub.stub else { return }
        if let error = stub.error {
            client?.urlProtocol(self, didFailWithError: error)
        }
        client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() { }
}
