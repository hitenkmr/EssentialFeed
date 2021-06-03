//
//  RemoteFeedImageDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Hitender Kumar on 03/06/21.
//

import XCTest
import EssentialFeed

class RemoteFeedImageDataLoader {
    
    init(client: Any) {
        
    }
}

class RemoteFeedImageDataLoaderTests: XCTestCase {
    
    func test_init_DoesNotPerformAnyURLRequest() {
        let (_,client) = makeSUT()
        XCTAssertEqual(client.requestedURLs.count, 0)
    }
    
    //MARK: HELPERS
    
    private func makeSUT() -> (sut: RemoteFeedImageDataLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedImageDataLoader(client: client)
        trackForMemoryLeaks(instance: client)
        trackForMemoryLeaks(instance: sut)
        return (sut, client)
    }
    
    private class HTTPClientSpy {
        var requestedURLs = [URL]()
    }
}
