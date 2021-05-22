//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Hitender Kumar on 18/02/21.
//

import Foundation

public typealias LoadFeedResult = Result<[FeedImage], Error>

public protocol FeedLoader {
    func load(completion : @escaping (LoadFeedResult) -> Void)
} 
