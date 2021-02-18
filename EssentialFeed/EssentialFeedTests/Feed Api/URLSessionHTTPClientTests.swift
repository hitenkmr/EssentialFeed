//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Hitender Kumar on 18/02/21.
//

import Foundation
import XCTest

class URLSessionHTTPClient {
    private let session : URLSession
    
    init(session : URLSession) {
        self.session = session
    }
    
    func get(from url : URL) {
        self.session.dataTask(with: url, completionHandler: { data, response, error in })
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    
    func test_getFromURL_creates_dataTaskWithUrl() {
        let url = URL(string: "http://any-url.com")!
        let session = URLSessionSpy()
        let sut = URLSessionHTTPClient(session: session)
        sut.get(from: url)
        XCTAssertEqual(session.receivedURLs, [url])
    }
}

//MARK: HELPERS

private class URLSessionSpy: URLSession {
    
    var receivedURLs = [URL]()
    
    override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
         self.receivedURLs.append(url)
        return FakeURLSessionDataTask()
    }
}

private class FakeURLSessionDataTask : URLSessionDataTask { }
