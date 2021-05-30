//
//  FeedImageCell.swift
//  EssentialFeediOS
//
//  Created by Hitender Kumar on 23/05/21.
//

import UIKit

public final class FeedImageCell: UITableViewCell {
    @IBOutlet private(set) public var locationContainer: UIView!
    @IBOutlet private(set) public var locationLabel: UILabel!
    @IBOutlet private(set) public var feedImageContainer: UIView!
    @IBOutlet private(set) public var feedImageView: UIImageView!
    @IBOutlet private(set) public var descriptionLabel: UILabel!
    @IBOutlet private(set) public var feedImageRetryBtn: UIButton!
     
    var onRetry: (() -> Void)?
    
    @IBAction func retryButtonTapped() {
        onRetry?()
    }
}
