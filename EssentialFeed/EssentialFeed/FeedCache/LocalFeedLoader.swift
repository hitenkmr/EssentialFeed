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
    private let calendar = Calendar(identifier: .gregorian)
        
    public init(store: FeedStore, currentDate: @escaping () -> Date = Date.init, date: Date = Date()) {
        self.store = store
        self.currentDate = currentDate
    }
    
    private var maxCacheAgeInDays: Int {
        return 7
    }
    
    private func validate(_ timestamp: Date) -> Bool {
        guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else { return false}
        return currentDate() < maxCacheAge
    }
}

extension LocalFeedLoader {
    
    public typealias SaveResult = Error?

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
    
    private func cache(feed: [FeedImage], with completion: @escaping (_ error: SaveResult) -> Void) {
        store.insert(feed: feed.toLocal(), timestamp: currentDate()) { [weak self] (error) in
            guard self != nil else { return }
            completion(error)
        }
    }
}

extension LocalFeedLoader: FeedLoader {
    
    public typealias LoadResult = LoadFeedResult

    public func load(completion: @escaping (_ result : LoadResult) -> Void) {
        self.store.retrieve { [weak self] cacheResult in
            guard let weak_self = self else { return }
            switch cacheResult {
            case let.failure(error):
                completion(.failure(error))
                
            case let.found(feed, timestamp) where weak_self.validate(timestamp):
                completion(.success(feed.toModels()))
                
            case .found, .empty:
                completion(.success([]))
            }
        }
    }
}

extension LocalFeedLoader {
    
    public func validateCache() {
        store.retrieve(completion: { [weak self] result in
            guard let weak_self = self else { return }
            switch result {
            case .failure:
                weak_self.store.deleteCachedFeed(completion: { _ in })
                
            case let.found(feed: _, timestamp) where !weak_self.validate(timestamp):
                weak_self.store.deleteCachedFeed(completion: { _ in })
                
            case .empty, .found: break
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
