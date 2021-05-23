//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Hitender Kumar on 23/05/21.
//

import XCTest
import UIKit
import EssentialFeed

final class FeedViewController: UIViewController {
    
    private var laoder: FeedLoader?
    
    convenience init(loader: FeedLoader) {
        self.init()
        laoder = loader
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        laoder?.load(completion: { _ in })
    }
}

class FeedViewControllerTests: XCTestCase {
 
    func test_init_doesNotLoadFeed() {
        let (_, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    func test_viewDidLoad_loadsFeed() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCallCount, 1)
    }
     
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        trackForMemoryLeaks(instance: loader, file: file, line: line)
        trackForMemoryLeaks(instance: sut, file: file, line: line)
        return (sut, loader)
    }
    
    class LoaderSpy: FeedLoader {
        
        private(set)var loadCallCount: Int = 0
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            self.loadCallCount += 1
        }
    }
}
