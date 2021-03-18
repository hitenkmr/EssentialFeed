//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Hitender Kumar on 17/03/21.
//

import XCTest
@testable import EssentialFeed

class CodableFeedStore {
    
    private  struct Cache: Codable {
        let feed: [CodableFeedImage]
        let timestamp: Date
        
        var localFeed: [LocalFeedImage] {
            return feed.map({ $0.local })
        }
    }
    
    private struct CodableFeedImage: Codable {
        private var id : UUID
        private var description : String?
        private var location : String?
        private var url : URL
        
        init(_ image: LocalFeedImage) {
            id = image.id
            description = image.description
            location = image.location
            self.url = image.url
        }
        
        var local: LocalFeedImage {
            return LocalFeedImage(id: id, description: description, location: location, url: url)
        }
    }
    
    func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        guard let data = try? Data(contentsOf: storeURL) else {
            return completion(.empty)
        }
        
        let encoder = JSONDecoder()
        let cache = try! encoder.decode(Cache.self, from: data)
        completion(.found(feed: cache.feed.map({ $0.local }), timestamp: cache.timestamp))
    }
    
    private let storeURL: URL
    
    init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    func insert(feed: [LocalFeedImage] , timestamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
        
        let encoder = JSONEncoder()
        let cache = Cache(feed: feed.map( CodableFeedImage.init ), timestamp: timestamp)
        let encoded = try! encoder.encode(cache)
        try! encoded.write(to: storeURL)
        
        completion(nil)
    }
}


class CodableFeedStoreTests: XCTestCase {
    
    override func setUp() {
        super.setUp()

        try? FileManager.default.removeItem(at: self.storeURL())
    }
    
    override func tearDown() {
        super.tearDown()

        try? FileManager.default.removeItem(at: self.storeURL())
    }
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        
        let exp = expectation(description: "wait for completion")
        sut.retrieve { (result) in
            switch result {
            case .empty:
                break
            default:
                XCTFail("Extected empty result, got \(result) instead")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retrieve_hasNoSideEffectOnEmptyCache() {
        let sut = makeSUT()
        
        let exp = expectation(description: "wait for completion")
        sut.retrieve { (firstResult) in
            sut.retrieve { (secondResult) in
                switch (firstResult, secondResult) {
                case (.empty, .empty):
                    break
                default:
                    XCTFail("Expected retrieving twice from empty cache to deliver the same empty result, got \(firstResult) & \(secondResult) instead")
                }
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retrieve_afterInsertingToEmptyCache_deliversInsertedValues() {
        let sut = makeSUT()
        let timestamp = Date()
        let exp = expectation(description: "wait for completion")
        
        let insertedFeed = uniqueFeedImage().local
        
        sut.insert(feed: insertedFeed, timestamp: timestamp, completion: { insertionError in
            
            XCTAssertNil(insertionError)
            
            sut.retrieve { (retrieveResult) in
                switch retrieveResult {
                case let.found(retrievedFeed, retrievedTimestamp):
                    XCTAssertEqual(retrievedFeed, insertedFeed)
                    XCTAssertEqual(retrievedTimestamp, timestamp)
                    break
                default:
                    XCTFail("Extected found result with feed \(insertedFeed) and timestamp \(timestamp), got \(retrieveResult) instead")
                }
                exp.fulfill()
            }
        })
        
        wait(for: [exp], timeout: 1.0)
    }
    
    //MARK: Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> CodableFeedStore {
        let sut = CodableFeedStore(storeURL: storeURL())
        trackForMemoryLeaks(instance: sut, file: file, line: line)
        return sut
    }
    
    private func storeURL() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")
    }
} 
