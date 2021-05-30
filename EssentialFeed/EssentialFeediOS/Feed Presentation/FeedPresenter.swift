//
//  FeedPresenter.swift
//  EssentialFeediOS
//
//  Created by Hitender Kumar on 30/05/21.
//

import Foundation
import EssentialFeed

struct FeedLoadingViewModel {
    var isLoading: Bool
}

protocol FeedLoadingView {
    func display(viewModel: FeedLoadingViewModel)
}

struct FeedViewModel {
    var feed: [FeedImage]
}

protocol FeedView {
    func display(viewModel: FeedViewModel)
}

final class FeedPresenter {
    
    typealias Observer<T> = (T) -> Void
    
    private let feedLoader: FeedLoader
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    var feedView: FeedView?
    var loadingView: FeedLoadingView?
    
    func loadFeed() {
        self.loadingView?.display(viewModel: FeedLoadingViewModel(isLoading: true))
        feedLoader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.feedView?.display(viewModel: FeedViewModel(feed: feed))
            }
            self?.loadingView?.display(viewModel: FeedLoadingViewModel(isLoading: false))
        }
    }
}
