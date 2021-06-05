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
        case let .success(imageFeed)?:
            XCTAssertEqual(imageFeed.count, 8, "Expected 8 items in the test account feed")
            XCTAssertEqual(imageFeed[0], extectedImage(at: 0), "Unexpected image value at index \(0)")
            XCTAssertEqual(imageFeed[1], extectedImage(at: 1), "Unexpected image value at index \(1)")
            XCTAssertEqual(imageFeed[2], extectedImage(at: 2), "Unexpected image value at index \(2)")
            XCTAssertEqual(imageFeed[3], extectedImage(at: 3), "Unexpected image value at index \(3)")
            XCTAssertEqual(imageFeed[4], extectedImage(at: 4), "Unexpected image value at index \(4)")
            XCTAssertEqual(imageFeed[5], extectedImage(at: 5), "Unexpected image value at index \(5)")
            XCTAssertEqual(imageFeed[6], extectedImage(at: 6), "Unexpected image value at index \(6)")
            XCTAssertEqual(imageFeed[7], extectedImage(at: 7), "Unexpected image value at index \(7)")
        case let .failure(error):
            XCTFail("Expected successfull image result, got \(error) instead.")
        default:
            XCTFail("Expected feed result, got no result instead")
        }
    }
    
    func test_endToEndTestServerGETFeedImageDataResult_matchesFixedTestAccountData() {
        switch getFeedImageDataResult() {
        case let .success(data)?:
            XCTAssertFalse(data.isEmpty, "Expected non-empty image data")
            
        case let .failure(error)?:
            XCTFail("Expected successful image data result, got \(error) instead")
            
        default:
            XCTFail("Expected successful image data result, got no result instead")
        }
    }
    
    // MARK: - Helpers
    
    private func getFeedImageDataResult(file: StaticString = #file, line: UInt = #line) -> FeedImageDataLoader.Result? {
        let testServerURL = URL(string: "https://essentialdeveloper.com/feed-case-study/test-api/feed/73A7F70C-75DA-4C2E-B5A3-EED40DC53AA6/image")!
        let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        let loader = RemoteFeedImageDataLoader(client: client)
        trackForMemoryLeaks(instance: client, file: file, line: line)
        trackForMemoryLeaks(instance: loader, file: file, line: line)
        
        let exp = expectation(description: "Wait for load completion")
        
        var receivedResult: FeedImageDataLoader.Result?
        _ = loader.loadImageData(from: testServerURL) { result in
            receivedResult = result
            exp.fulfill()
        }
        wait(for: [exp], timeout: 5.0)
        
        return receivedResult
    }
    
    private func getFeedResult(file: StaticString = #filePath, line: UInt = #line) -> FeedLoader.Result? {
        let testServerUrl = URL(string: "https://essentialdeveloper.com/feed-case-study/test-api/feed")!
        let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        let loader = RemoteFeedLoader(url: testServerUrl, client: client)
        
        trackForMemoryLeaks(instance: client, file : file, line : line)
        trackForMemoryLeaks(instance: loader, file : file, line : line)
        
        let exp = expectation(description: "wait for load completion")
        
        var receivedResult : FeedLoader.Result?
        
        loader.load { (result) in
            receivedResult = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 10.0)
        return receivedResult
    }
    
    private func extectedImage(at index : Int) -> FeedImage {
        return FeedImage(id: uuID(at: index), description: description(at: index), location: location(at: index), url: imageUrl(at: index))
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
