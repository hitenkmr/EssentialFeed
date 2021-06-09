//
//  CoreDataFeedStore+FeedStore.swift .swift
//  EssentialFeed
//
//  Created by Hitender Kumar on 09/06/21.
//

import CoreData

extension CoreDataFeedStore: FeedStore {
    public func retrieve(completion: @escaping RetrievalCompletion) {
        perform { context in
            completion(Result {
                try ManagedCache.find(in: context).map({
                    CachedFeed($0.localFeed, $0.timestamp)
                })
            })
        }
    }
    
    public func insert(feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        perform { context in
            completion(Result {
                let managedCache = try ManagedCache.newUniqueInstance(in: context)
                managedCache.timestamp = timestamp
                managedCache.feed = ManagedFeedImage.images(from: feed, in: context)
                
                try context.save()
            })
        }
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        perform { context in
            completion(Result {
                try ManagedCache.find(in: context).map(context.delete).map(context.save)
            })
        }
    }
}
