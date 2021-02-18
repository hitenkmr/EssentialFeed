//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Hitender Kumar on 18/02/21.
//

import Foundation

public enum LoadFeedResult {
    case success([FeedItem])
    case failure(Error)
}

protocol FeedLoader {
    func load(completion : @escaping (LoadFeedResult) -> Void)
} 
