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
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) {
        client.get(from: url, completion: { result in
            switch result {
            case let .failure(error): completion(.failure(error))
            default: break
            }
        })
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
    
    func test_loadImageDataFromURLTwice_requestsDataFromURLTwice() {
        let (sut,client) = makeSUT()
        let url = anyURL()
        sut.loadImageData(from: url, completion: { _ in })
        sut.loadImageData(from: url, completion: { _ in })
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_loadImageDataFromURL_deliversErrorOnClientError() {
        let (sut,client) = makeSUT()
        let clientError = anyNSError()
        expect(sut, toCompleteWith: .failure(clientError)) {
            client.complete(with: clientError)
        }
    }
    
    //MARK: HELPERS
    
    private func makeSUT() -> (sut: RemoteFeedImageDataLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedImageDataLoader(client: client)
        trackForMemoryLeaks(instance: client)
        trackForMemoryLeaks(instance: sut)
        return (sut, client)
    }
    
    private func expect(_ sut: RemoteFeedImageDataLoader, toCompleteWith expectedResult: FeedImageDataLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        
        let url = anyURL()
        let exp = expectation(description: "Wait for load completion")
        
        sut.loadImageData(from: url, completion: { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)
                
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                
            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        })
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private class HTTPClientSpy: HTTPClient {
        
        var requestedURLs: [URL] {
            self.messages.map({ $0.url })
        }
        
        var messages = [(url: URL, completion: (HTTPClient.Result) -> Void)]()
        
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
    }
}
