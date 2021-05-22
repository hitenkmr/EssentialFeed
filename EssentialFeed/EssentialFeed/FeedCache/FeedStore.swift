//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Hitender Kumar on 08/03/21.
//

import Foundation

public typealias CachedFeed = (feed: [LocalFeedImage], timestamp: Date)
 
public protocol FeedStore {
    
    typealias DeletionResult = Result<Void, Error>
    typealias DeletionCompletion = (DeletionResult) -> Void
    
    typealias InsertionResult = Result<Void, Error>
    typealias InsertionCompletion = (InsertionResult) -> Void
    
    typealias RetrievalResult = Swift.Result<CachedFeed?, Error>
    typealias RetrievalCompletion = (RetrievalResult) -> Void

    ///The completion handler can be invoked in any thread(main thread if to update the UI OR background thread if some non-UI work needs to be done).
    ///Clients are responsible to dispatch to appropriate threah, if needed.
    func insert(feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion)
    
    ///The completion handler can be invoked in any thread(main thread if to update the UI OR background thread if some non-UI work needs to be done).
    ///Clients are responsible to dispatch to appropriate threah, if needed.
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    
    ///The completion handler can be invoked in any thread(main thread if to update the UI OR background thread if some non-UI work needs to be done).
    ///Clients are responsible to dispatch to appropriate threah, if needed.
    func retrieve(completion: @escaping RetrievalCompletion)
}
