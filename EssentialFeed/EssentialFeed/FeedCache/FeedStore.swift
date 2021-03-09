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
    
    func insert(items: [LocalFeedItem], timestamp: Date, completion: @escaping InsertionCompletion)
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
}

public struct LocalFeedItem : Equatable {
    var id : UUID
    var description : String?
    var location : String?
    var imageUrl : URL
}
