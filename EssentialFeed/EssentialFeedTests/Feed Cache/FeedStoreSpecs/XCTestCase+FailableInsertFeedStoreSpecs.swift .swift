//
//  XCTestCase+FailableInsertFeedStoreSpecs.swift .swift
//  EssentialFeedTests
//
//  Created by Hitender Kumar on 17/04/21.
//

import XCTest
import EssentialFeed

extension FailableInsertFeedStoreSpecs where Self: XCTestCase {
    func assertThatInsertDeliversErrorOnInsertionError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        let insertionError = insert(sut, uniqueFeedImage().local, Date())

        XCTAssertNotNil(insertionError, "Expected cache insertion to fail with an error", file: file, line: line)
    }

    func assertThatInsertHasNoSideEffectsOnInsertionError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        insert(sut, uniqueFeedImage().local, Date())
        expect(sut: sut, toRetrieve: .empty, file: file, line: line)
    }
}
