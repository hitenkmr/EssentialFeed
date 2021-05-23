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
        let loader = LoaderSpy()
        _ = FeedViewController(loader: loader)
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    func test_viewDidLoad_loadsFeed() {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCallCount, 1)
    }
     
    class LoaderSpy: FeedLoader {
        
        private(set)var loadCallCount: Int = 0
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            self.loadCallCount += 1
        }
    }
}
