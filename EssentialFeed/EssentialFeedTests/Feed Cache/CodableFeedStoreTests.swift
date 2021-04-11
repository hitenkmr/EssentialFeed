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
        
        do {
            let decoder = JSONDecoder()
            let cache = try decoder.decode(Cache.self, from: data)
            completion(.found(feed: cache.feed.map({ $0.local }), timestamp: cache.timestamp))
        }
        catch {
            completion(.failure(error))
        }
    }
    
    func deleteCachedFeed(completion: @escaping FeedStore.DeletionCompletion) {
        guard FileManager.default.fileExists(atPath: storeURL.path) else {
            return completion(nil)
        }
        
        try! FileManager.default.removeItem(at: storeURL)
        completion(nil)
    }
    
    private let storeURL: URL
    
    init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    func insert(feed: [LocalFeedImage] , timestamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
        
        do {
            let encoder = JSONEncoder()
            let cache = Cache(feed: feed.map( CodableFeedImage.init ), timestamp: timestamp)
            let encoded = try encoder.encode(cache)
            try encoded.write(to: storeURL)
            completion(nil)
        } catch {
            completion(error)
        }
    }
}


class CodableFeedStoreTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        
        undoSideEffects()
    }
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        
        expect(sut: sut, toRetrieve: .empty)
    }
    
    func test_retrieve_hasNoSideEffectOnEmptyCache() {
        let sut = makeSUT()
        
        expectRetrieveTwice(sut: sut, toRetrieve: .empty)
    }
    
    func test_retrieve_deliversFoundValuesOnEmptyCache() {
        let sut = makeSUT()
        let timestamp = Date()
        let insertedFeed = uniqueFeedImage().local
        
        insert(sut, insertedFeed, timestamp)

        expect(sut: sut, toRetrieve: .found(feed: insertedFeed, timestamp: timestamp))
    }
    
    func test_retrieve_hasNoSideEffectOnNonEmptyCache() {
        let sut = makeSUT()
        let timestamp = Date()
        let insertedFeed = uniqueFeedImage().local

        insert(sut, insertedFeed, timestamp)
        
        expect(sut: sut, toRetrieve: .found(feed: insertedFeed, timestamp: timestamp))
    }
    
    func test_retrieveDeliversFailureOnRetrievalError() {
        let storeURL = testSpecificStoreURL()
        
        let sut = makeSUT(storeURL: storeURL)
        
        try! "invalid data".write(to: testSpecificStoreURL(), atomically: false, encoding: .utf8)
        
        expect(sut: sut, toRetrieve: .failure(anyNSError()))
    }
    
    func test_retrieveHasNoSideEffectOnFailure() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)
        
        try! "invalid data".write(to: testSpecificStoreURL(), atomically: false, encoding: .utf8)
        
        expectRetrieveTwice(sut: sut, toRetrieve: .failure(anyNSError()))
    }
    
    func test_insert_overridesPreviouslyInsertedCacheValues() {
        let sut = makeSUT()
        
        let firstInsertionError = insert(sut, uniqueFeedImage().local, Date())
        XCTAssertNil(firstInsertionError, "Expected to insert cache successfully")
        
        let latestFeed = uniqueFeedImage().local
        let latestTimestamp = Date()
        let latestInsertionError = insert(sut, latestFeed, latestTimestamp)
        
        XCTAssertNil(latestInsertionError, "Expected to override cache successfully")

        expect(sut: sut, toRetrieve: .found(feed: latestFeed, timestamp: latestTimestamp))
    }
    
    func test_delivers_errorOnInsertionError() {
        let invalidStoreURL = URL(string: "invalid://store-url")!
        let sut = makeSUT(storeURL: invalidStoreURL)
        
        let feed = uniqueFeedImage().local
        let timestamp = Date()
        let insertionError = insert(sut, feed, timestamp)
        
        XCTAssertNotNil(insertionError, "Expected cache insertion to fail with an error")

    }
    
    func test_delete_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        let exp = expectation(description: "Wait for cache deletion")
        
        sut.deleteCachedFeed { deletionError in
            XCTAssertNil(deletionError, "Expected empty cache deletion to succeed")
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        
        expect(sut: sut, toRetrieve: .empty)
    }
    
    func test_delete_emptiesPreviouslyInsertedCache() {
        let sut = makeSUT()
        insert(sut, uniqueFeedImage().local, Date())
        
        let exp = expectation(description: "Wait for cache deletion")
        sut.deleteCachedFeed { deletionError in
            XCTAssertNil(deletionError, "Expected non-empty cache deletion to succeed")
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        
        expect(sut: sut, toRetrieve: .empty)
    }
    
    //MARK: Helpers
    
    private func makeSUT(storeURL: URL? = nil, file: StaticString = #filePath, line: UInt = #line) -> CodableFeedStore {
        let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL())
        trackForMemoryLeaks(instance: sut, file: file, line: line)
        return sut
    }
    
    private func setupEmptyStoreState() {
        deleteStoreArtifacts()
     }
    
    private func undoSideEffects() {
        deleteStoreArtifacts()
    }
    
    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: self.testSpecificStoreURL())
    }
    
    private func testSpecificStoreURL() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
    }
    
    private func expectRetrieveTwice(sut: CodableFeedStore, toRetrieve expectedResult: RetrieveCacheFeedResult, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut: sut, toRetrieve: expectedResult)
        expect(sut: sut, toRetrieve: expectedResult)
    }
        
   @discardableResult
    private func insert(_ sut: CodableFeedStore, _ insertedFeed: [LocalFeedImage], _ timestamp: Date) -> Error? {
        let exp = expectation(description: "wait for cache retrieval")
        var insertionError: Error?
        
        sut.insert(feed: insertedFeed, timestamp: timestamp, completion: { onInsertionError in
            insertionError = onInsertionError
            exp.fulfill()
        })
        wait(for: [exp], timeout: 1.0)
        return insertionError
    }
    
    private func expect(sut: CodableFeedStore, toRetrieve expectedResult: RetrieveCacheFeedResult, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "wait for cache retrieval")
        
        sut.retrieve { (retrievedResult) in
            switch (expectedResult, retrievedResult) {
            case (.empty, .empty), (.failure, .failure):
                break
            case let (.found(expected, expectedTimestamp), .found(retrieved, retrievedTimestamp)):
                XCTAssertEqual(expected, retrieved)
                XCTAssertEqual(expectedTimestamp, retrievedTimestamp)
                break
            default:
                XCTFail("Extected retrievinng \(expectedResult), got \(retrievedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
}
