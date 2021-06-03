//
//  RemoteFeedImageDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Hitender Kumar on 03/06/21.
//

import XCTest
import EssentialFeed

class RemoteFeedImageDataLoader {
    
    private let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func loadImageData(from url: URL, completion: @escaping (Any) -> Void) {
        client.get(from: url, completion: { _ in })
    }
}

class RemoteFeedImageDataLoaderTests: XCTestCase {
    
    func test_init_DoesNotPerformAnyURLRequest() {
        let (_,client) = makeSUT()
        XCTAssertEqual(client.requestedURLs.count, 0)
    }
    
    func test_loadImageDataFromURL_requestsDataFromURL() {
        let (sut,client) = makeSUT()
        let url = anyURL()
        sut.loadImageData(from: url, completion: { _ in })
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    //MARK: HELPERS
    
    private func makeSUT() -> (sut: RemoteFeedImageDataLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedImageDataLoader(client: client)
        trackForMemoryLeaks(instance: client)
        trackForMemoryLeaks(instance: sut)
        return (sut, client)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var requestedURLs = [URL]()
        
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
            requestedURLs.append(url)
        }
    }
}
