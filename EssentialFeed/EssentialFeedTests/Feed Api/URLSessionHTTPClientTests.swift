//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Hitender Kumar on 18/02/21.
//

import Foundation
import XCTest
@testable import EssentialFeed

protocol HTTPSession {
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionDataTask
}

protocol HTTPSessionDataTask {
    func resume()
}

class URLSessionHTTPClient {
    private let session : HTTPSession
    
    init(session : HTTPSession) {
        self.session = session
    }
    
    func get(from url : URL, completion : @escaping (HTTPClientResult) -> Void) {
        self.session.dataTask(with: url, completionHandler: { data, response, error in
            if let error = error {
                completion(.failure(error))
            }
        }).resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    
    func test_getFromURL_resumesDtaaTaskWithUrl() {
        let url = URL(string: "http://any-url.com")!
        let session = HTTPSessionSpy()
        
        let task = HTTPSessionDataTaskSpy()
        session.stub(url: url, task: task)
        
        let sut = URLSessionHTTPClient(session: session)
        sut.get(from: url, completion: { _ in })
        
        XCTAssertEqual(task.resumeCallsCount, 1)
    }
    
    func test_getFromURL_failsOnRequestError() {
        let url = URL(string: "http://any-url.com")!
        let session = HTTPSessionSpy()
        
        let error = NSError(domain: "error completion call", code: 0, userInfo: nil)
        session.stub(url: url, error: error)
        
        let sut = URLSessionHTTPClient(session: session)
        
        let exp = expectation(description: "wait for compeltion")
        sut.get(from: url, completion: { result in
            switch result {
            case let .failure(receivedError as NSError):
                XCTAssertEqual(receivedError, error)
            default:
                XCTFail("Expected failure with error \(error), got result \(result)")
            }
            exp.fulfill()
        })
        
        wait(for: [exp], timeout: 1.0)
    }
}

//MARK: HELPERS

private class HTTPSessionSpy: HTTPSession {
    
    private var stubs = [URL : Stub]()
    
    private struct Stub {
        let task : HTTPSessionDataTask
        let error : Error?
    }
    
    func stub(url : URL, task : HTTPSessionDataTask = FakeURLSessionDataTask(), error : Error? = nil) {
        stubs[url] = .init(task: task, error: error)
    }
    
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionDataTask {
        guard let stub = stubs[url] else {
            fatalError("Coundn't find stub for \(url)")
        }
        completionHandler(nil, nil, stub.error)
        return stub.task
    }
}

private class FakeURLSessionDataTask : HTTPSessionDataTask {
     func resume() { }
}

private class HTTPSessionDataTaskSpy : HTTPSessionDataTask {
    
    var resumeCallsCount = 0
    
    func resume() {
        resumeCallsCount += 1
    }
}
