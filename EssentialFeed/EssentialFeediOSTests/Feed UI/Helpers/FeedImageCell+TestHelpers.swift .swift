//
//  FeedImageCell+TestHelpers.swift .swift
//  EssentialFeediOSTests
//
//  Created by Hitender Kumar on 24/05/21.
//

import UIKit
import EssentialFeediOS

extension FeedImageCell {
    func simulateRetryAction() {
        feedImageRetryBtn.simulateTap()
    }

    var isShowingLocation: Bool {
        return !locationContainer.isHidden
    }

    var isShowingImageLoadingIndicator: Bool {
        return feedImageContainer.isShimmering
    }

    var isShowingRetryAction: Bool {
        return !feedImageRetryBtn.isHidden
    }

    var locationText: String? {
        return locationLabel.text
    }

    var descriptionText: String? {
        return descriptionLabel.text
    }

    var renderedImage: Data? {
        return feedImageView.image?.pngData()
    }
}
