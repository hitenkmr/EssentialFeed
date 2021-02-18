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
        self.session.dataTask(with: url, completionHandler: { data, response, error in }).resume()
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
    
    
    func test_getFromURL_resumesDtaaTaskWithUrl() {
        let url = URL(string: "http://any-url.com")!
        let session = URLSessionSpy()
        
        let task = URLSessionDataTaskSpy()
        session.stup(url: url, task: task)
        
        let sut = URLSessionHTTPClient(session: session)
        sut.get(from: url)
        
        XCTAssertEqual(task.resumeCallsCount, 1)
    }
}

//MARK: HELPERS

private class URLSessionSpy: URLSession {
    
    var receivedURLs = [URL]()
    
    private var stubs = [URL : URLSessionDataTask]()
    
    func stup(url : URL, task : URLSessionDataTask) {
        stubs[url] = task
    }
    
    override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
         self.receivedURLs.append(url)
        return stubs[url] ?? FakeURLSessionDataTask()
    }
}

private class FakeURLSessionDataTask : URLSessionDataTask {
    override func resume() { }
}

private class URLSessionDataTaskSpy : URLSessionDataTask {
    
    var resumeCallsCount = 0
    
    override func resume() {
        resumeCallsCount += 1
    }
}
