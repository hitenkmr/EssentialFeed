//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Hitender Kumar on 08/03/21.
//

import Foundation

public final class LocalFeedLoader {
    
    private let store: FeedStore
    private let currentDate: () -> Date
    
    public typealias SaveResult = Error?
    public typealias LoadResult = LoadFeedResult

    public init(store: FeedStore, currentDate: @escaping () -> Date = Date.init, date: Date = Date()) {
        self.store = store
        self.currentDate = currentDate
    }
    
    public func save(_ feed: [FeedImage], completion: @escaping (_ error: SaveResult) -> Void) {
        store.deleteCachedFeed { [weak self] (error) in
            guard let self = self else { return }
            if let cacheDeletionError = error {
                completion(cacheDeletionError)
            } else {
                self.cache(feed: feed, with: completion)
            }
        }
    }
    
    public func load(completion: @escaping (_ result : LoadResult) -> Void) {
        self.store.retrieve { cacheResult in
            switch cacheResult {
            case let.failure(error):
                completion(.failure(error))
            case .empty:
                completion(.success([]))
            case let.found(feed, _):
                completion(.success(feed.toModels()))
            }
        }
    }
    
    private func cache(feed: [FeedImage], with completion: @escaping (_ error: SaveResult) -> Void) {
        store.insert(feed: feed.toLocal(), timestamp: currentDate()) { [weak self] (error) in
            guard self != nil else { return }
            completion(error)
        }
    }
}

private extension Array where Element == FeedImage {
    func toLocal() -> [LocalFeedImage] {
        map({ LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)})
    }
}

private extension Array where Element == LocalFeedImage {
    func toModels() -> [FeedImage] {
        map({ FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)})
    }
}
