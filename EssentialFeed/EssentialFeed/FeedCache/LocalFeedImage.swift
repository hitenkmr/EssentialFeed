//
//  LocalFeedItem.swift
//  EssentialFeed
//
//  Created by Hitender Kumar on 09/03/21.
//

import Foundation

// Instead of always passing models across boundaries, consider using a data transfer representation (also known as data transfer objects or DTO).

public struct LocalFeedImage : Equatable, Codable {
    var id : UUID
    var description : String?
    var location : String?
    var url : URL
}
