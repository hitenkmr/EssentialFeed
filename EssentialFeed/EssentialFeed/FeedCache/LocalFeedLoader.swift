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
    
    public init(store: FeedStore, currentDate: @escaping () -> Date = Date.init) {
        self.store = store
        self.currentDate = currentDate
    }
}

extension LocalFeedLoader {
    
    public typealias SaveResult = Result<Void, Error>
    
    public func save(_ feed: [FeedImage], completion: @escaping (_ error: SaveResult) -> Void) {
        store.deleteCachedFeed { [weak self] deletionResult in
            guard let self = self else { return }
            switch deletionResult {
            case .success:
                self.cache(feed: feed, with: completion)
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    private func cache(feed: [FeedImage], with completion: @escaping (_ error: SaveResult) -> Void) {
        store.insert(feed: feed.toLocal(), timestamp: self.currentDate()) { [weak self] (error) in
            guard self != nil else { return }
            completion(error)
        }
    }
}

extension LocalFeedLoader: FeedLoader {
    
    public typealias LoadResult = FeedLoader.Result
    
    public func load(completion: @escaping (_ result : LoadResult) -> Void) {
        self.store.retrieve { [weak self] cacheResult in
            guard let weak_self = self else { return }
            switch cacheResult {
            case let.failure(error):
                completion(.failure(error))
                
            case let.success(.some(cache)) where FeedCachePolicy.validate(cache.timestamp, against: weak_self.currentDate()):
                completion(.success(cache.feed.toModels()))
                
            case .success(.some), .success(.none):
                completion(.success([]))
            }
        }
    }
}

extension LocalFeedLoader {
    
    public typealias ValidationResult = Result<Void, Error>
    
    public func validateCache(completion: @escaping (ValidationResult) -> Void = { _ in }) {
        store.retrieve(completion: { [weak self] result in
            guard let weak_self = self else { return }
            switch result {
            case .failure:
                weak_self.store.deleteCachedFeed(completion: { _ in completion(.success(()))})
                
            case let.success(.some(cache)) where !FeedCachePolicy.validate(cache.timestamp, against: weak_self.currentDate()):
                weak_self.store.deleteCachedFeed(completion: { _ in  completion(.success(())) })
                
            case .success:
                completion(.success(()))
            }
        })
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

