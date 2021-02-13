//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by Mac Book on 13/02/21.
//

import Foundation

public struct FeedItem : Equatable {
    var id : UUID
    var description : String?
    var location : String?
    var imageUrl : URL
}
