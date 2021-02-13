//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by Hitender Kumar on 13/02/21.
//

import Foundation

internal final class FeedItemsMapper {
    
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
        
        var feed : [FeedItem] {
            items.map({ $0.item })
        }
    }
    
    private static var OK_200 : Int { return 200 }
   
    internal static func map(data : Data, from response : HTTPURLResponse) -> RemoteFeedLoader.Result {
        guard response.statusCode == OK_200, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            return .failure([.invalidData])
        }
        return .success(root.feed)
    }
}
