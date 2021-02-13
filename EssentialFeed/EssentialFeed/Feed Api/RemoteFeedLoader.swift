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
    
    public enum Result : Equatable {
        case success([FeedItem])
        case failure([Error])
    }
    
    public init(url : URL, client : HTTPClient) {
        self.client = client
        self.url = url
    }
    
    public func load(completion : @escaping (Result) -> Void) {
        client.get(url: url, completion: { result in
            switch result {
            case let.success(data, response):
                do {
                    let items = try FeedItemsMapper.map(data, response)
                    completion(.success(items))
                } catch  {
                    completion(.failure([.invalidData]))
                }
            case .failure:
                completion(.failure([.connectivity]))
            }
        })
    }
}
