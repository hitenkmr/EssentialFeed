//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Hitender Kumar on 08/03/21.
//

import Foundation

public protocol FeedStore {
    
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    typealias ReterievalCompletion = (Error?) -> Void

    func insert(feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion)
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    func retrieve(completion: @escaping ReterievalCompletion)
}
