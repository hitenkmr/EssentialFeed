//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Hitender Kumar on 18/02/21.
//

import Foundation

public protocol FeedLoader {
    typealias Result = Swift.Result<[FeedImage], Error>
    func load(completion : @escaping (Result) -> Void)
} 
