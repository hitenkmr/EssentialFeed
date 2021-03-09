//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Hitender Kumar on 09/03/21.
//

import Foundation

// Instead of always passing models across boundaries, consider using a data transfer representation (also known as data transfer objects or DTO).

internal struct RemoteFeedItem : Decodable {
    internal var id : UUID
    internal var description : String?
    internal var location : String?
    internal var image : URL
}
