//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Hitender Kumar on 17/03/21.
//

import XCTest
@testable import EssentialFeed

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
        
        let sut = makeSUT(storeURL: storeURL) //given
        
        try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8) //when
        
        expect(sut: sut, toRetrieve: .failure(anyNSError())) //then
    }
    
    func test_retrieveHasNoSideEffectOnFailure() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)
        
        try! "invalid data".write(to: testSpecificStoreURL(), atomically: false, encoding: .utf8)
        
        expectRetrieveTwice(sut: sut, toRetrieve: .failure(anyNSError()))
    }
    
    func test_insert_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()
        let feed = uniqueFeedImage().local
        let insertionError = insert(sut, feed, Date())
        XCTAssertNil(insertionError, "Expected to insert cache successfully")
    }
    
    func test_insert_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()
        insert(sut, uniqueFeedImage().local, Date())
        
        let insertionError = insert(sut, uniqueFeedImage().local, Date())
        
        XCTAssertNil(insertionError, "Expected to override cache successfully")
    }
    
    func test_insert_overridesPreviouslyInsertedCacheValues() {
        let sut = makeSUT()
        
        let firstInsertionError = insert(sut, uniqueFeedImage().local, Date())
        XCTAssertNil(firstInsertionError, "Expected to insert cache successfully")
        
        let latestFeed = uniqueFeedImage().local
        let latestTimestamp = Date()
        
        insert(sut, latestFeed, latestTimestamp)
        
        expect(sut: sut, toRetrieve: .found(feed: latestFeed, timestamp: latestTimestamp))
    }
    
    func test_insert_deliversErrorOnInsertionError() {
        let invalidStoreURL = URL(string: "invalid://store-url")!
        let sut = makeSUT(storeURL: invalidStoreURL)
        
        let feed = uniqueFeedImage().local
        let timestamp = Date()
        let insertionError = insert(sut, feed, timestamp)
        
        XCTAssertNotNil(insertionError, "Expected cache insertion to fail with an error")
    }
    
    func test_inset_hasNoSideEffectOnInsertionError() {
        let invalidStoreURL = URL(string: "invalid://store-url")!
        let sut = makeSUT(storeURL: invalidStoreURL)
        
        let feed = uniqueFeedImage().local
        let timestamp = Date()
        
        insert(sut, feed, timestamp)
        
        expect(sut: sut, toRetrieve: .empty)
    }
    
    func test_delete_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()
        let deletionError = deleteCache(from: sut)
        
        XCTAssertNil(deletionError, "Expected empty cache deletion to succeed")
    }
    
    func test_delete_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()
        insert(sut, uniqueFeedImage().local, Date())
        
        let deletionError = deleteCache(from: sut)
        
        XCTAssertNil(deletionError, "Expected non-empty cache deletion to succeed")
    }
    
    func test_delete_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        
        deleteCache(from: sut)
        
        expect(sut: sut, toRetrieve: .empty)
    }
    
    func test_delete_emptiesPreviouslyInsertedCache() {
        let sut = makeSUT()
        insert(sut, uniqueFeedImage().local, Date())
        
        deleteCache(from: sut)
        
        expect(sut: sut, toRetrieve: .empty)
    }
    
    func test_delete_deliversErrorOnDeletionError() {
        //the cache directory folder that we cannot delete
        let noDeletePermissionURL = cachesDirectory()
        let sut = makeSUT(storeURL: noDeletePermissionURL)
        
        let deletionError = deleteCache(from: sut)
        
        XCTAssertNotNil(deletionError, "Expected cache deletion to fail")
    }
    
    func test_delete_hasNoSideEffectsOnDeletionError() {
        let noDeletePermissionURL = cachesDirectory()
        let sut = makeSUT(storeURL: noDeletePermissionURL)
        
        deleteCache(from: sut)
        
        expect(sut: sut, toRetrieve: .empty)
    }
    
    func test_operationsRunsSerially() {
        let sut = makeSUT()
        
        var completedOperationsInOrder = [XCTestExpectation]()
        
        let op1 = expectation(description: "insert")
        
        sut.insert(feed: uniqueFeedImage().local, timestamp: Date()) { (error) in
            op1.fulfill()
            completedOperationsInOrder.append(op1)
        }
        
        let op2 = expectation(description: "delete")

        sut.deleteCachedFeed { (error) in
            op2.fulfill()
            completedOperationsInOrder.append(op2)
        }
        
        let op3 = expectation(description: "insert2")

        sut.insert(feed: uniqueFeedImage().local, timestamp: Date()) { (error) in
            op3.fulfill()
            completedOperationsInOrder.append(op3)
        }
        
        wait(for: [op1, op2, op3], timeout: 5.0)
        XCTAssertEqual(completedOperationsInOrder, [op1, op2, op3], "Expected side-effects to run serially but they exectued in wrong order")
    }
    
    //MARK: Helpers
    
    private func makeSUT(storeURL: URL? = nil, file: StaticString = #filePath, line: UInt = #line) -> FeedStore {
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
        return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
    }
    
    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    private func expectRetrieveTwice(sut: FeedStore, toRetrieve expectedResult: RetrieveCacheFeedResult, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut: sut, toRetrieve: expectedResult)
        expect(sut: sut, toRetrieve: expectedResult)
    }
        
   @discardableResult
    private func insert(_ sut: FeedStore, _ insertedFeed: [LocalFeedImage], _ timestamp: Date) -> Error? {
        let exp = expectation(description: "wait for cache retrieval")
        var insertionError: Error?
        
        sut.insert(feed: insertedFeed, timestamp: timestamp, completion: { onInsertionError in
            insertionError = onInsertionError
            exp.fulfill()
        })
        wait(for: [exp], timeout: 1.0)
        return insertionError
    }
    
    private func expect(sut: FeedStore, toRetrieve expectedResult: RetrieveCacheFeedResult, file: StaticString = #filePath, line: UInt = #line) {
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
    
    @discardableResult
    private func deleteCache(from sut: FeedStore) -> Error? {
        let exp = expectation(description: "Wait for cache deletion")
        var deletionError: Error?
        sut.deleteCachedFeed { receivedDeletionError in
            deletionError = receivedDeletionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return deletionError
    }
}
