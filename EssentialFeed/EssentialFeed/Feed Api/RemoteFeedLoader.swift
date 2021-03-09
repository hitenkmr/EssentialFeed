//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Hitender Kumar on 07/02/21.
//

import Foundation

/**
 The RemoteFeedLoader does not need to locate or instantiate HTTPClient instance. Instead we can make our code more modular by injecting HTTPClient as a dependency.
 */
public final class RemoteFeedLoader : FeedLoader {
    
    private let url : URL
    private let client : HTTPClient
    
    public enum Error : Swift.Error {
        case connectivity
        case invalidData
    }
    
    public typealias Result = LoadFeedResult
    
    public init(url : URL, client : HTTPClient) {
        self.client = client
        self.url = url
    }
    
    public func load(completion : @escaping (Result) -> Void) {
        client.get(from: url, completion: { [weak self] result in
            guard self != nil else { return }
            switch result {
            case let.success(data, response):
                completion(RemoteFeedLoader.map(data, response: response))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        })
    }
    
    private static func map(_ data : Data, response : HTTPURLResponse) -> Result {
        do {
            let items = try FeedItemsMapper.map(data: data, from: response)
            return .success(items.toModles())
        } catch  {
            return .failure(error)
        }
    }
}

private extension Array where Element == RemoteFeedItem {
    func toModles() -> [FeedItem] {
        return map({ FeedItem(id: $0.id, description: $0.description, location: $0.location, imageUrl: $0.image) })
    }
}
