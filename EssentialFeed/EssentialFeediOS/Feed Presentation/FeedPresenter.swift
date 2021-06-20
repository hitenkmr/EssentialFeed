//
//  FeedPresenter.swift
//  EssentialFeediOS
//
//  Created by Hitender Kumar on 30/05/21.
//

import Foundation
import EssentialFeed

public protocol FeedLoadingView {
    func display(viewModel: FeedLoadingViewModel)
}

public protocol FeedView {
    func display(viewModel: FeedViewModel)
}

public final class FeedPresenter {
    
    typealias Observer<T> = (T) -> Void
    
    private let feedView: FeedView
    private let loadingView: FeedLoadingView
    
    public init(feedView: FeedView, loadingView: FeedLoadingView) {
        self.feedView = feedView
        self.loadingView = loadingView
    }
    
    public static var title: String {
        NSLocalizedString("FEED_VIEW_TITLE",
                          tableName: "Feed",
                          bundle: Bundle(for: FeedPresenter.self),
                          comment: "Title for the feed view")
    }
    
    public func didStartLoadingFeed() {
        loadingView.display(viewModel: FeedLoadingViewModel(isLoading: true))
    }
    
    public func didFinishLoadingFeed(with feed: [FeedImage]) {
        feedView.display(viewModel: FeedViewModel(feed: feed))
        loadingView.display(viewModel: FeedLoadingViewModel(isLoading: false))
    }
    
    public func didFinishLoadingFeed(with error: Error) {
        loadingView.display(viewModel: FeedLoadingViewModel(isLoading: false))
    }
}
