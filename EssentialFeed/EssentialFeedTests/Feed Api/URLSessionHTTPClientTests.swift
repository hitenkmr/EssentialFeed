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
    
    struct UnExpectedValuesRepresentation : Error {}
    
    func get(from url : URL, completion : @escaping (HTTPClientResult) -> Void) {
        self.session.dataTask(with: url, completionHandler: { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data, data.count > 0, let response = response as? HTTPURLResponse {
                completion(.success(data, response))
            } else {
                completion(.failure(UnExpectedValuesRepresentation()))
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
        URLProtocolStub.observeRequests { (request) in
            XCTAssertEqual(request.url, self.anyUrl())
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        makeSUT().get(from: anyUrl(), completion: { _ in })
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_getFromURL_failsOnRequestError() {
        let requestError = anyNSError()
        let receivedEror = resultErrorFor(data: nil, resposne: nil, error: requestError) as NSError?
        XCTAssertEqual(receivedEror?.domain, requestError.domain)
    }
    
    func test_getFromURL_failsOnAllValidRepresentationCases() {
        //invalid cases
        XCTAssertNotNil(resultErrorFor(data: nil, resposne: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, resposne: nonHTTPUrlResposne(), error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, resposne: anyHTTPUrlResposne(), error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), resposne: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), resposne: nil, error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: nil, resposne: nonHTTPUrlResposne(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: nil, resposne: anyHTTPUrlResposne(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), resposne: nonHTTPUrlResposne(), error: anyNSError()))
        
        //valid cases
        XCTAssertNotNil(resultErrorFor(data: anyData(), resposne: anyHTTPUrlResposne(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), resposne: nonHTTPUrlResposne(), error: nil))
    }
    
    func test_getFromURL_suceedsOnHTTPURLResponseithData() {
        let requestedResponse = anyHTTPUrlResposne()
        let requestedData = anyData()
        URLProtocolStub.stub(data: requestedData, response: requestedResponse, error: nil)
        
        let exp = expectation(description: "wait for response")
        self.makeSUT().get(from: anyUrl()) { (result) in
            switch result {
            case let .success(receivedData, receivedResponse):
                XCTAssertEqual(requestedResponse.url, receivedResponse.url)
                XCTAssertEqual(requestedResponse.statusCode, receivedResponse.statusCode)
                XCTAssertEqual(requestedData, receivedData)
            default:
                XCTFail("requested error, got \(result) instead")
                break
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    //MARK: HELPERS
    
    private func resultErrorFor(data : Data?, resposne : URLResponse?, error:  Error?, file : StaticString = #file, line : UInt = #line) -> Error? {
        URLProtocolStub.stub(data: data, response: resposne, error: error)
        
        let exp = expectation(description: "wait for completion")
        
        var receivedError: Error?
        
        let sut = makeSUT(line :line, file : file)
        sut.get(from: anyUrl()) { (result) in
            switch result {
            case let .failure(error):
                receivedError = error
            default:
                XCTFail("Expected failure, got result \(result)")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        return receivedError
    }
    
    private func anyUrl() -> URL {
        return URL(string: "http://any-url.com")!
    }
    
    private func anyData() -> Data {
        return "any data".data(using: .utf8)!
    }
    
    private func nonHTTPUrlResposne() -> URLResponse {
        return URLResponse(url: anyUrl(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    private func anyHTTPUrlResposne() -> HTTPURLResponse{
        return HTTPURLResponse(url: anyUrl(), statusCode: 200, httpVersion: nil, headerFields: nil)!
    }
    
    private func anyNSError() -> NSError {
        return  NSError(domain: "any error", code: 1)
    }
    
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
        let data : Data?
        let response : URLResponse?
        let error : Error?
    }
    
    static func stub(data : Data? = nil, response : URLResponse? = nil, error : Error? = nil) {
        stub = .init(data : data, response : response, error: error)
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
        
        if let data = URLProtocolStub.stub?.data {
            client?.urlProtocol(self, didLoad: data)
        }
        
        if let response = URLProtocolStub.stub?.response {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }
        
        if let error = URLProtocolStub.stub?.error {
            client?.urlProtocol(self, didFailWithError: error)
        }
        
        client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() { }
}
