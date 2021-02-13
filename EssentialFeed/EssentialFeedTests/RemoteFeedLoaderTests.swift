//
//  RemoteFeedLoader.swift
//  EssentialFeedTests
//
//  Created by Mac Book on 07/02/21.
//

import UIKit
import XCTest
@testable import EssentialFeed

class HttpClientSpy: HTTPClient {
    
    private var messages = [(url : URL, completion : (((HTTPClientResult))->Void))]()
    
    var requestedUrls : [URL] {
        return messages.map({ $0.url })
    }
    
    func get(url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        messages.append((url, completion))
    }
    
    func complete(with error : Error, index : Int = 0) {
        messages[index].completion(HTTPClientResult.failure(error))
    }
    
    func complete(withStatusCode : Int, data : Data = Data(), at index : Int = 0) {
        let response = HTTPURLResponse(url: messages[index].url, statusCode: withStatusCode, httpVersion: nil, headerFields: nil)!
        messages[index].completion(.success(data, response))
    }
}

class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromUrl() {
        let (_, client) = makeSUT()
        XCTAssertTrue(client.requestedUrls.isEmpty)
    }
    
    func test_init_RequestsDataFromUrl() {
        let url = URL(string: "http://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        sut.load { _ in }
        XCTAssertEqual(client.requestedUrls, [url])
    }
    
    func test_loadTwice_requestsDatFromUrlTwice() {
        let url = URL(string: "http://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        sut.load { _ in }
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedUrls, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWithError: .connectivity, when: {
            let clientError = NSError(domain: "Test", code: 0, userInfo: nil)
            client.complete(with: clientError, index: 0)
        })
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        let samples = [199, 201, 300, 400, 500]
        samples.enumerated().forEach { (index, code) in
            expect(sut, toCompleteWithError: .invalidData) {
                client.complete(withStatusCode: code, at: index)
            }
        }
    }
    
    func test_load_deliversInvalidDataOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWithError: .invalidData) {
            let invalidData : Data = "".data(using: .utf8)!
            client.complete(withStatusCode: 200, data: invalidData, at: 0)
        }
    }
    
    //MARK: HELPERS
    
    private func makeSUT(url : URL = URL(string: "http://a-url.com")!) -> (sut : RemoteFeedLoader, client : HttpClientSpy) {
        let client = HttpClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    private func expect(_ sut : RemoteFeedLoader, toCompleteWithError error : RemoteFeedLoader.Error, when action : () -> Void, message : String = "Test failed", file: StaticString = #filePath, line: UInt = #line) {
        var capturedErrors = [RemoteFeedLoader.Error]()
        sut.load(completion: { capturedErrors.append($0) })
        action()
        XCTAssertEqual(capturedErrors, [error], message, file: file, line: line)
    }
}
