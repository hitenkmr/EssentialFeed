//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by Mac Book on 13/02/21.
//

import Foundation

public struct FeedItems : Decodable {
    var items : [FeedItem]
}

public struct FeedItem : Equatable {
    var id : UUID
    var description : String?
    var location : String?
    var imageUrl : String
}

extension FeedItem : Decodable {
    
    private enum CodingKeys : String, CodingKey {
        case id = "id"
        case description = "description"
        case location = "location"
        case imageUrl = "url"
        
    }
}
