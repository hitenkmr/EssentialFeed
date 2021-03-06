//
//  EssentialFeedAPIEndToEndTests.swift
//  EssentialFeedAPIEndToEndTests
//
//  Created by Hitender Kumar on 22/02/21.
//

import XCTest
@testable import EssentialFeed

class EssentialFeedAPIEndToEndTests: XCTestCase {
    
    func test_endToEndServerGetFeedResult_matchesFixedTestAccountData() {
        switch getFeedResult() {
        case let .success(items)?:
            XCTAssertEqual(items.count, 8, "Expected 8 items in the test account feed")
            XCTAssertEqual(items[0], extectedItem(at: 0), "Unexpected item value at index \(0)")
            XCTAssertEqual(items[1], extectedItem(at: 1), "Unexpected item value at index \(1)")
            XCTAssertEqual(items[2], extectedItem(at: 2), "Unexpected item value at index \(2)")
            XCTAssertEqual(items[3], extectedItem(at: 3), "Unexpected item value at index \(3)")
            XCTAssertEqual(items[4], extectedItem(at: 4), "Unexpected item value at index \(4)")
            XCTAssertEqual(items[5], extectedItem(at: 5), "Unexpected item value at index \(5)")
            XCTAssertEqual(items[6], extectedItem(at: 6), "Unexpected item value at index \(6)")
            XCTAssertEqual(items[7], extectedItem(at: 7), "Unexpected item value at index \(7)")
        case let .failure(error):
            XCTFail("Expected successfull feed result, got \(error) instead.")
        default:
            XCTFail("Expected feed result, got not result instead")
        }
    }
    
    private func getFeedResult() -> LoadFeedResult? {
        let testServerUrl = URL(string: "https://essentialdeveloper.com/feed-case-study/test-api/feed")!
        let client = URLSessionHTTPClient()
        let loader = RemoteFeedLoader(url: testServerUrl, client: client)
        let exp = expectation(description: "wait for load completion")
        
        var receivedResult : LoadFeedResult?
        
        loader.load { (result) in
            receivedResult = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 10.0)
        return receivedResult
    }
    
    private func extectedItem(at index : Int) -> FeedItem {
        return FeedItem(id: uuID(at: index), description: description(at: index), location: location(at: index), imageUrl: imageUrl(at: index))
    }
    
    private func uuID(at index :Int) -> UUID {
        let id = ["73A7F70C-75DA-4C2E-B5A3-EED40DC53AA6",
                  "BA298A85-6275-48D3-8315-9C8F7C1CD109",
                  "5A0D45B3-8E26-4385-8C5D-213E160A5E3C",
                  "FF0ECFE2-2879-403F-8DBE-A83B4010B340",
                  "DC97EF5E-2CC9-4905-A8AD-3C351C311001",
                  "557D87F1-25D3-4D77-82E9-364B2ED9CB30",
                  "A83284EF-C2DF-415D-AB73-2A9B8B04950B",
                  "F79BD7F8-063F-46E2-8147-A67635C3BB01"][index]
        return UUID(uuidString: id)!
    }
    
    private func description(at index :Int) -> String? {
        return ["Description 1",
                nil,
                "Description 3",
                nil,
                "Description 5",
                "Description 6",
                "Description 7",
                "Description 8"][index]
    }
    
    private func location(at index :Int) -> String? {
        return ["Location 1",
                "Location 2",
                nil,
                nil,
                "Location 5",
                "Location 6",
                "Location 7",
                "Location 8"][index]
    }
    
    private func imageUrl(at index :Int) -> URL {
        let string = ["https://url-1.com",
                      "https://url-2.com",
                      "https://url-3.com",
                      "https://url-4.com",
                      "https://url-5.com",
                      "https://url-6.com",
                      "https://url-7.com",
                      "https://url-8.com"][index]
        return URL(string: string)!
    }
}
