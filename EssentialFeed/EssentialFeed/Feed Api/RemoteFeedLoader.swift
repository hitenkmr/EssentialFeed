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
public final class RemoteFeedLoader {
    
    private let url : URL
    private let client : HTTPClient
    
    public enum Error : Swift.Error {
        case connectivity
        case invalidData
    }
    
    public typealias Result = LoadFeedResult<Error>
    
    public init(url : URL, client : HTTPClient) {
        self.client = client
        self.url = url
    }
    
    public func load(completion : @escaping (Result) -> Void) {
        client.get(url: url, completion: { [weak self] result in
            guard self != nil else { return }
            switch result {
            case let.success(data, response):
                completion(FeedItemsMapper.map(data: data, from: response))
            case .failure:
                completion(.failure([.connectivity]))
            }
        })
    }
}
