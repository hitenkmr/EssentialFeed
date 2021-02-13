//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Mac Book on 07/02/21.
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
            case let.success(data, _):
                do {
                    let items = try JSONDecoder().decode(FeedItems.self, from: data)
                    completion(.success(items.items))
                } catch  {
                    completion(.failure([.invalidData]))
                }
            case let .failure(_):
                completion(.failure([.connectivity]))
            }
        })
    }
}

/**
 By creating a clean seperation with protocols, we made the RemoteFeedLoader more flexible, open for extension and more testable
 
 The HTTPClient does not need to be a class . it is just a contract defining which external functinality the RemoteFeedLoader needs, so a protocol is more suitable way to define it.
 */

public protocol HTTPClient {
    func get(url : URL, completion : @escaping (HTTPClientResult) -> Void)
}

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}
