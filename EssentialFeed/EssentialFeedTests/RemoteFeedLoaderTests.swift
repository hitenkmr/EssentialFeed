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
    
    func getFeed(url: URL) {
        self.requestedUrl = url
    }
    
    var requestedUrl : URL?
    
}

class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromUrl() {
        let (_, client) = makeSUT()
        XCTAssertNil(client.requestedUrl)
    }
    
    func test_init_RequestDataFromUrl() {
        let url = URL(string: "http://a-given-url.com")!
         let (sut, client) = makeSUT(url: url)
        sut.load()
        XCTAssertEqual(client.requestedUrl, url)
    }
    
    //MARK: HELPERS
    
    private func makeSUT(url : URL = URL(string: "http://a-url.com")!) -> (sut : RemoteFeedLoader, client : HttpClientSpy) {
        let client = HttpClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
}
