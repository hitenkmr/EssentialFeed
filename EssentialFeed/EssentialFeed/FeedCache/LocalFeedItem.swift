//
//  LocalFeedItem.swift
//  EssentialFeed
//
//  Created by Hitender Kumar on 09/03/21.
//

import Foundation

public struct LocalFeedItem : Equatable {
    var id : UUID
    var description : String?
    var location : String?
    var imageUrl : URL
}
