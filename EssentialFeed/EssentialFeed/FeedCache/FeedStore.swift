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
    
    func insert(items: [FeedItem], timestamp: Date, completion: @escaping InsertionCompletion)
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
}
