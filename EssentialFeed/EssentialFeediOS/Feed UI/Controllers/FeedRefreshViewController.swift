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
    @IBOutlet weak var view: UIRefreshControl?
    
    var deleagte: FeedRefreshViewControllerDelegate?
    
    @IBAction func refresh() {
        deleagte?.didRequestFeedRefresh()
    }
    
    func display(viewModel: FeedLoadingViewModel)  {
        if viewModel.isLoading {
            view?.beginRefreshing()
        } else {
            view?.endRefreshing()
        }
    }
}
