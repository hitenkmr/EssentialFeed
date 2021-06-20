//
//  FeedCache.swift
//  EssentialFeed
//
//  Created by Hitender Kumar on 20/06/21.
//

import Foundation

public protocol FeedCache {
    typealias Result = Swift.Result<Void, Error>

    func save(_ feed: [FeedImage], completion: @escaping (Result) -> Void)
}
