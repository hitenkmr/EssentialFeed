//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by Hitender Kumar on 13/02/21.
//

import Foundation

internal struct RemoteFeedItem : Decodable {
    internal var id : UUID
    internal var description : String?
    internal var location : String?
    internal var image : URL
}

internal final class FeedItemsMapper {
    
    private struct Root : Decodable {
        var items : [RemoteFeedItem]
    }
    
    private static var OK_200 : Int { return 200 }
    
    internal static func map(data : Data, from response : HTTPURLResponse) throws -> [RemoteFeedItem] {
        
        guard response.statusCode == OK_200,
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteFeedLoader.Error.invalidData
        }
        return root.items
    }
}
