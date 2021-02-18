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
    
    func test_getFromURL_failsOnRequestError() {
        
        URLProtocolStub.startInterceptingUrlRequests()
        
        let url = URL(string: "http://any-url.com")!
        let error = NSError(domain: "error completion call", code: 1)
        
        URLProtocolStub.stub(url: url, error: error)
        let sut = URLSessionHTTPClient()
        
        let exp = expectation(description: "wait for compeltion")
        
        sut.get(from: url) { result in
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
        
        URLProtocolStub.stopInterceptingUrlRequests()
    }
}

//MARK: HELPERS

private class URLProtocolStub: URLProtocol {
    
    private static var stubs = [URL : Stub]()
    
    private struct Stub {
        let error : Error?
    }
    
    static func stub(url : URL, error : Error? = nil) {
        stubs[url] = .init(error: error)
    }
    
    static func startInterceptingUrlRequests() {
        URLProtocolStub.registerClass(URLProtocolStub.self)
    }
    
    static func stopInterceptingUrlRequests() {
        URLProtocolStub.unregisterClass(URLProtocolStub.self)
        stubs = [:]
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
        guard let url = request.url else { return false }
        return URLProtocolStub.stubs[url] != nil
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        guard let url = request.url, let stub = URLProtocolStub.stubs[url] else { return }
        if let error = stub.error {
            client?.urlProtocol(self, didFailWithError: error)
        }
        client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() { }
}
