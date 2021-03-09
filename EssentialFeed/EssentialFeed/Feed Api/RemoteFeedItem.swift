//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Hitender Kumar on 09/03/21.
//

import Foundation

internal struct RemoteFeedItem : Decodable {
    internal var id : UUID
    internal var description : String?
    internal var location : String?
    internal var image : URL
}
