//
//  FeedCacheTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Hitender Kumar on 15/03/21.
//

import Foundation
@testable import EssentialFeed

func uniqueImage() -> FeedImage {
    FeedImage(id: UUID(), description: "any", location: "any", url: anyURL())
}

func uniqueFeedImage() -> (models: [FeedImage], local: [LocalFeedImage]) {
    let models = [uniqueImage(), uniqueImage()]
    let local = models.map({ LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) })
    
    return (models: models, local: local)
}

func anyNSError() -> NSError {
    return  NSError(domain: "any error", code: 1)
}

extension Date {
    func adding(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
    
    func adding(seconds: TimeInterval) -> Date {
        return  self + seconds
    }
}
