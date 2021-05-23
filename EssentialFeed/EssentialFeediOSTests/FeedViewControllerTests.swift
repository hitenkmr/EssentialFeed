//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Hitender Kumar on 23/05/21.
//

import XCTest
import UIKit

final class FeedViewController: UIViewController {
    
    private var laoder: FeedViewControllerTests.LoaderSpy?
    
    convenience init(loader: FeedViewControllerTests.LoaderSpy) {
        self.init()
        laoder = loader
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        laoder?.load()
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
    
    class LoaderSpy {
        private(set)var loadCallCount: Int = 0
        
        func load() {
            self.loadCallCount += 1
        }
    }
}
