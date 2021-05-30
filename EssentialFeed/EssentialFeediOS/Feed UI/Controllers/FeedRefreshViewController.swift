//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Hitender Kumar on 24/05/21.
//

import UIKit

protocol FeedRefreshViewControllerDelegate {
    func didRequestFeedRefresh()
}

final class FeedRefreshViewController: NSObject, FeedLoadingView {
    private(set) lazy var view = loadView()
    
    private let deleagte: FeedRefreshViewControllerDelegate
    
    init(deleagte: FeedRefreshViewControllerDelegate) {
        self.deleagte = deleagte
    }
    
    @objc func refresh() {
        deleagte.didRequestFeedRefresh()
    }
    
    func display(viewModel: FeedLoadingViewModel)  {
        if viewModel.isLoading {
            view.beginRefreshing()
        } else {
            view.endRefreshing()
        }
    }
    
    private func loadView() -> UIRefreshControl {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
}
