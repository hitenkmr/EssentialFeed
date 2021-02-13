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
    
    private var messages = [(url : URL, completion : (((HTTPClientResult))->Void))]()
    
    var requestedUrls : [URL] {
        return messages.map({ $0.url })
    }
    
    func get(url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        messages.append((url, completion))
    }
    
    func complete(with error : Error, index : Int = 0) {
        messages[index].completion(HTTPClientResult.failure(error))
    }
    
    func complete(withStatusCode : Int, data : Data = Data(), at index : Int = 0) {
        let response = HTTPURLResponse(url: messages[index].url, statusCode: withStatusCode, httpVersion: nil, headerFields: nil)!
        messages[index].completion(.success(data, response))
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
        expect(sut, toCompleteWithResult:.failure([.connectivity])) {
            let clientError = NSError(domain: "Test", code: 0, userInfo: nil)
            client.complete(with: clientError, index: 0)
        }
    } 
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        let samples = [199, 201, 300, 400, 500]
        samples.enumerated().forEach { (index, code) in
            expect(sut, toCompleteWithResult:.failure([.invalidData])) {
                client.complete(withStatusCode: code, at: index)
            }
        }
    }
    
    func test_load_deliversInvalidDataOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWithResult:.failure([.invalidData])) {
            let invalidData : Data = "".data(using: .utf8)!
            client.complete(withStatusCode: 200, data: invalidData, at: 0)
        }
    }
    
    func test_load_deliversNoItemsOn200ResponseCodeWithEmptyListJSON() {
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWithResult: .success([])) {
            let emptyJson = "{\"items\":[]}".data(using: .utf8)!
            client.complete(withStatusCode: 200, data: emptyJson, at: 0)
        }
    }
    
    func test_load_deliversItemsOn200ResponseCodeWithJSONItems() {
        let (sut, client) = makeSUT()
        let item1 = makeFeedItem(id: UUID(), description: "a desc", location: "a location", imageUrl: "http://some-a.com")
        let item2 = makeFeedItem(id: UUID(), description: "b desc", location: "b location", imageUrl: "http://some-b.com")
        expect(sut, toCompleteWithResult: .success([item1.modal, item2.modal])) {
            let data = makeJsonData(itemsJson: [item1.json, item2.json])
            client.complete(withStatusCode: 200, data: data, at: 0)
        }
    }
    
    //MARK: HELPERS
    
    private func makeSUT(url : URL = URL(string: "http://a-url.com")!) -> (sut : RemoteFeedLoader, client : HttpClientSpy) {
        let client = HttpClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    private func expect(_ sut : RemoteFeedLoader, toCompleteWithResult result : RemoteFeedLoader.Result, when action : () -> Void, message : String = "Test failed", file: StaticString = #filePath, line: UInt = #line) {
        var capturedResults = [RemoteFeedLoader.Result]()
        sut.load(completion: { capturedResults.append($0) })
        action()
        XCTAssertEqual(capturedResults, [result], message, file: file, line: line)
    }
    
    private func makeFeedItem(id: UUID, description : String? = nil, location : String? = "a location", imageUrl: String) ->(modal : FeedItem, json : [String : Any]) {
        let item = FeedItem(id: id, description: description, location: location, imageUrl: imageUrl)
        let itemJson = ["id" : item.id.uuidString, "description" : item.description, "url" : item.imageUrl, "location" : item.location].reduce(into: [String : Any](), { (acc, e) in
            if let value = e.value { acc[e.key] = value }
        })
        return (item, itemJson)
    }
    
    private func makeJsonData(itemsJson : [[String : Any]]) -> Data {
        let data = try! JSONSerialization.data(withJSONObject: ["items" : itemsJson], options: .prettyPrinted)
        return data
    }
}
