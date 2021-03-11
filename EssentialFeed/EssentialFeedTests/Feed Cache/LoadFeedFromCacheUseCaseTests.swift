//
//  LoadFeedFromCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Hitender Kumar on 11/03/21.
//

import EssentialFeed
import XCTest

class LoadFeedFromCacheUseCaseTests: XCTestCase {

    func test_init_doesNotStoreMessageUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_load_requestsCacheRetrieval() {
        let (sut, store) = makeSUT()
        sut.load(completion: { _ in })
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_failsRetrievalError() {
        let (sut, store) = makeSUT()
        
        let exp = expectation(description: "wait for completion")
        
        var receivedError : Error?
        let expectedError = anyNSError()
        
        sut.load { (error) in
            receivedError = error
            exp.fulfill()
        }
        
        store.completeRetrieval(with: expectedError)
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedError as NSError?, expectedError)
    }
    
    //MARK: Helpers
    
    private func makeSUT(date: Date = Date(), currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(instance: store, file: file, line: line)
        trackForMemoryLeaks(instance: sut, file: file, line: line)
        return (sut, store)
    }
    
    private func anyNSError() -> NSError {
        return  NSError(domain: "any error", code: 1)
    }
}
