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
        
    private var messages = [(url : URL, completion : ((Error?, HTTPURLResponse?)->Void))]()
    
    var requestedUrls : [URL] {
        return messages.map({ $0.url })
    }

    func get(url: URL, completion: @escaping (Error?, HTTPURLResponse?) -> Void) {
        messages.append((url, completion))
    }
    
    func complete(with error : Error, index : Int = 0) {
        messages[index].completion(error, nil)
    }
    
    func complete(withStatusCode : Int, at index : Int = 0) {
        let response = HTTPURLResponse(url: messages[index].url, statusCode: withStatusCode, httpVersion: nil, headerFields: nil)
        messages[index].completion(nil, response)
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
        var capturedErrors = [RemoteFeedLoader.Error]()
        sut.load(completion: { capturedErrors.append($0) })
        let clientError = NSError(domain: "Test", code: 0, userInfo: nil)
        client.complete(with: clientError, index: 0)
        XCTAssertEqual(capturedErrors, [.connectivity])
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        var capturesErrors = [RemoteFeedLoader.Error]()
        sut.load(completion: { capturesErrors.append($0) })
        client.complete(withStatusCode: 400)
        XCTAssertEqual(capturesErrors, [.invalidData])
        
    }
    
    //MARK: HELPERS
    
    private func makeSUT(url : URL = URL(string: "http://a-url.com")!) -> (sut : RemoteFeedLoader, client : HttpClientSpy) {
        let client = HttpClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
}
