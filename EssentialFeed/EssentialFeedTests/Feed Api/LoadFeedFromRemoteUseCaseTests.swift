//
//  LoadFeedFromRemoteUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Hitender Kumar on 07/02/21.
//

import Foundation
import XCTest
@testable import EssentialFeed

class HttpClientSpy: HTTPClient {
    
    private var messages = [(url : URL, completion : (((HTTPClient.Result))->Void))]()
    
    var requestedUrls : [URL] {
        return messages.map({ $0.url })
    }
    
    func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
        messages.append((url, completion))
    }
    
    func complete(with error : Error, index : Int = 0) {
        messages[index].completion(HTTPClient.Result.failure(error))
    }
    
    func complete(withStatusCode : Int, data : Data, at index : Int = 0) {
        let response = HTTPURLResponse(url: messages[index].url, statusCode: withStatusCode, httpVersion: nil, headerFields: nil)!
        messages[index].completion(.success((data, response)))
    }
}

class LoadFeedFromRemoteUseCaseTests: XCTestCase {
    
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
        expect(sut, toCompleteWith: failure(.connectivity)) {
            let clientError = NSError(domain: "Test", code: 0, userInfo: nil)
            client.complete(with: clientError, index: 0)
        }
    } 
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        let samples = [199, 201, 300, 400, 500]
        samples.enumerated().forEach { (index, code) in
            expect(sut, toCompleteWith: failure(.invalidData)) {
                let data = makeJsonData(itemsJson: [])
                client.complete(withStatusCode: code, data : data, at: index)
            }
        }
    }
    
    func test_load_deliversInvalidDataOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWith: failure(.invalidData)) {
            let invalidData = Data("".utf8)
            client.complete(withStatusCode: 200, data: invalidData, at: 0)
            
        }
    }
    
    func test_load_deliversNoItemsOn200ResponseCodeWithEmptyListJSON() {
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWith: .success([])) {
            let emptyJson = Data("{\"items\":[]}".utf8)
            client.complete(withStatusCode: 200, data: emptyJson, at: 0)
        }
    }
    
    func test_load_deliversItemsOn200ResponseCodeWithJSONItems() {
        let (sut, client) = makeSUT()
        let item1 = makeFeedItem(id: UUID(), description: "a desc", location: "a location", imageUrl: URL(string: "http://some-a.com")!)
        let item2 = makeFeedItem(id: UUID(), description: "b desc", location: "b location", imageUrl: URL(string: "http://some-b.com")!)
        expect(sut, toCompleteWith: .success([item1.modal, item2.modal])) {
            let data = makeJsonData(itemsJson: [item1.json, item2.json])
            client.complete(withStatusCode: 200, data: data, at: 0)
        }
    }
    
    func test_load_doesNotDeliverResultAfterSUTInatanceHasBeenDeallocated() {
        let url = URL(string: "http://some-url.com")!
        let client = HttpClientSpy()
        var sut : RemoteFeedLoader? = RemoteFeedLoader(url: url, client: client)
        
        var capturedResults = [RemoteFeedLoader.Result]()
        sut?.load(completion: { capturedResults.append($0) })
        
        sut = nil
        client.complete(withStatusCode: 200, data: makeJsonData(itemsJson: []))
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    //MARK: HELPERS
    
    private func failure(_ error : RemoteFeedLoader.Error) -> RemoteFeedLoader.Result {
        return RemoteFeedLoader.Result.failure(error)
    }
    
    private func makeSUT(url : URL = URL(string: "http://a-url.com")!, file: StaticString = #filePath, line: UInt = #line) -> (sut : RemoteFeedLoader, client : HttpClientSpy) {
        let client = HttpClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        trackForMemoryLeaks(instance: sut)
        trackForMemoryLeaks(instance: client)
        return (sut, client)
    }
    
    private func expect(_ sut : RemoteFeedLoader, toCompleteWith expectedResult : RemoteFeedLoader.Result, when action : () -> Void, message : String = "Test failed", file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "wait for load completion")
        sut.load(completion: { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, message, file: file, line: line)
                
            case let (.failure(receivedError as RemoteFeedLoader.Error), .failure(expectedError as RemoteFeedLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, message, file: file, line: line)
                
            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead.", file: file, line: line)
            }
            exp.fulfill()
        })
        action()
        wait(for: [exp], timeout: 1.0)
    }
    
    private func makeFeedItem(id: UUID, description : String? = nil, location : String? = "a location", imageUrl: URL) ->(modal : FeedImage, json : [String : Any]) {
        let item = FeedImage(id: id, description: description, location: location, url: imageUrl)
        let itemJson = ["id" : item.id.uuidString, "description" : item.description, "image" : item.url.absoluteString, "location" : item.location].compactMapValues({ $0 })
        return (item, itemJson)
    }
    
    private func makeJsonData(itemsJson : [[String : Any]]) -> Data {
        let data = try! JSONSerialization.data(withJSONObject: ["items" : itemsJson], options: .prettyPrinted)
         return data
    }
}
