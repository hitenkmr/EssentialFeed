//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by Hitender Kumar on 13/02/21.
//

import Foundation

internal final class FeedItemsMapper {
    
    private struct Root : Decodable {
        var items : [RemoteFeedItem]
    }
    
    internal static func map(data : Data, from response : HTTPURLResponse) throws -> [RemoteFeedItem] {
        
        guard response.isOK, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteFeedLoader.Error.invalidData
        }
        return root.items
    }
}
