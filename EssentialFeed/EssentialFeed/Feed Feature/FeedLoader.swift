//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Hitender Kumar on 18/02/21.
//

import Foundation

public enum LoadFeedResult {
    case success([FeedImage])
    case failure(Error)
}

public protocol FeedLoader {
    func load(completion : @escaping (LoadFeedResult) -> Void)
} 
