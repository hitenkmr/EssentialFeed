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

private class FeedItemsMapper {
    
    private struct Item : Decodable {
        var id : UUID
        var description : String?
        var location : String?
        var image : URL
        
        var item : FeedItem {
            return FeedItem(id: id, description: description, location: location, imageUrl: image)
        }
    }

    private struct Root : Decodable {
        var items : [Item]
    }
    
    static func map(_ data : Data, _ response:  HTTPURLResponse) throws -> [FeedItem] {
        guard response.statusCode == 200 else {
            throw RemoteFeedLoader.Error.invalidData
        }
        return try JSONDecoder().decode(Root.self, from: data).items.map({ $0.item })
    }
}
