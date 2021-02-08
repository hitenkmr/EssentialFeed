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
    
    var completions = [(Error) -> Void]()
    
    private var messages = [(url : URL, completion : ((Error)->Void))]()
    
    var requestedUrls : [URL] {
        return messages.map({ $0.url })
    }

    func get(url: URL, completion: @escaping (Error) -> Void) {
        messages.append((url, completion))
        completions.append(completion)
    }
    
    func complete(with error : Error, index : Int = 0) {
        completions[index](error)
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
        sut.load()
        XCTAssertEqual(client.requestedUrls, [url])
    }
    
    func test_loadTwice_requestsDatFromUrlTwice() {
        let url = URL(string: "http://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        sut.load()
        sut.load()
        
        XCTAssertEqual(client.requestedUrls, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        var capturedError = [RemoteFeedLoader.Error]()
        sut.load(completion: { error in capturedError.append(error) })
        let clientError = NSError(domain: "Test", code: 0, userInfo: nil)
        client.complete(with: clientError, index: 0)
        XCTAssertEqual(capturedError, [.connectivity])
    }
    
    //MARK: HELPERS
    
    private func makeSUT(url : URL = URL(string: "http://a-url.com")!) -> (sut : RemoteFeedLoader, client : HttpClientSpy) {
        let client = HttpClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
}
