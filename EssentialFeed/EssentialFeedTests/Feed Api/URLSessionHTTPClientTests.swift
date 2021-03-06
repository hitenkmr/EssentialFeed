//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Hitender Kumar on 18/02/21.
//

import Foundation
import XCTest
@testable import EssentialFeed

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
        XCTAssertNotNil(resultErrorFor(data: anyData(), resposne: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), resposne: nil, error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: nil, resposne: nonHTTPUrlResposne(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: nil, resposne: anyHTTPUrlResposne(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), resposne: nonHTTPUrlResposne(), error: anyNSError()))
        
        //valid cases
        XCTAssertNotNil(resultErrorFor(data: anyData(), resposne: anyHTTPUrlResposne(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), resposne: nonHTTPUrlResposne(), error: nil))
    }
    
    func test_getFromURL_suceedsOnHTTPURLResponseWithData() {
        let requestedResponse = anyHTTPUrlResposne()
        let requestedData = anyData()
        let resultValues = resultValuesFor(data: anyData(), resposne: requestedResponse, error: nil)
        
        XCTAssertEqual(resultValues?.response.url, requestedResponse.url)
        XCTAssertEqual(resultValues?.response.statusCode, requestedResponse.statusCode)
        XCTAssertEqual(requestedData, resultValues?.data)
    }
    
    func test_getFromURL_suceedsWithEmptyDtaOnHTTPURLResponseWithNilData() {
        let requestedResponse = anyHTTPUrlResposne()
        let resultValues = resultValuesFor(data: nil, resposne: requestedResponse, error: nil)
        
        let emptyData = Data()
        XCTAssertEqual(resultValues?.response.url, requestedResponse.url)
        XCTAssertEqual(resultValues?.response.statusCode, requestedResponse.statusCode)
        XCTAssertEqual(resultValues?.data, emptyData)
    }
    
    //MARK: HELPERS
    
    private func resultErrorFor(data : Data?, resposne : URLResponse?, error:  Error?, file : StaticString = #file, line : UInt = #line) -> Error? {
        
        let result = self.resultFor(data: data, resposne: resposne, error: error, file : file, line: line)
        switch result {
        case let .failure(error):
            return error
        default:
            XCTFail("Expected failure, got result \(result)")
            return nil
        }
    }
    
    private func resultValuesFor(data : Data?, resposne : URLResponse?, error:  Error?, file : StaticString = #file, line : UInt = #line) -> (data : Data, response : HTTPURLResponse)? {
        
        let result = self.resultFor(data: data, resposne: resposne, error: error, file : file, line: line)
        
        switch result {
        case let .success(data, response):
            return (data, response)
        default:
            XCTFail("Expected success, got result \(result)")
            return nil
        }
    }
    
    private func resultFor(data : Data?, resposne : URLResponse?, error:  Error?, file : StaticString = #file, line : UInt = #line) -> HTTPClientResult {
        URLProtocolStub.stub(data: data, response: resposne, error: error)
        
        let exp = expectation(description: "wait for completion")
        
        var receivedResult: HTTPClientResult!
        
        let sut = makeSUT(line :line, file : file)
        sut.get(from: anyUrl()) { (result) in
            receivedResult = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        return receivedResult
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
    
    private func makeSUT(line : UInt = #line, file : StaticString = #file) -> HTTPClient {
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
        
        if let requestObserver = URLProtocolStub.requestObserver {
            client?.urlProtocolDidFinishLoading(self)
            return requestObserver(request)
        }
        
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
