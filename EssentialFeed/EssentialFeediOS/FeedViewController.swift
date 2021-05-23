//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Hitender Kumar on 23/05/21.
//

import UIKit
import EssentialFeed

final public class FeedViewController: UITableViewController {
    
    private var laoder: FeedLoader?
    
    public convenience init(loader: FeedLoader) {
        self.init()
        laoder = loader
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        load()
    }
    
    @objc private func load() {
        self.refreshControl?.beginRefreshing()
        laoder?.load(completion: { [weak self] _ in
            self?.refreshControl?.endRefreshing()
        })
    }
}
