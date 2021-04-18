//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Hitender Kumar on 18/04/21.
//

import Foundation

class CoreDataFeedStore: FeedStore {
    
    public init() {}
    
    func insert(feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
         
    }
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
         
    }
    
    func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.empty)
    }
}
