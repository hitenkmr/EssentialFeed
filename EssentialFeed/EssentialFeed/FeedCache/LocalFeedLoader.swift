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
    
    public init(store: FeedStore, currentDate: @escaping () -> Date = Date.init, date: Date = Date()) {
        self.store = store
        self.currentDate = currentDate
    }
    
    public func save(_ items: [FeedItem], completion: @escaping (_ error: SaveResult) -> Void) {
        store.deleteCachedFeed { [weak self] (error) in
            guard let self = self else { return }
            if let cacheDeletionError = error {
                completion(cacheDeletionError)
            } else {
                self.cache(items: items, with: completion)
            }
        }
    }
    
    private func cache(items: [FeedItem], with completion: @escaping (_ error: SaveResult) -> Void) {
        store.insert(items: items.toLocal(), timestamp: currentDate()) { [weak self] (error) in
            guard self != nil else { return }
            completion(error)
        }
    }
}

private extension Array where Element == FeedItem {
    func toLocal() -> [LocalFeedItem] {
        map({ LocalFeedItem(id: $0.id, description: $0.description, location: $0.location, imageUrl: $0.imageUrl)})
    }
}
