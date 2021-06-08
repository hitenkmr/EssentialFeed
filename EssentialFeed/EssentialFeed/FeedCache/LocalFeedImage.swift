//
//  LocalFeedItem.swift
//  EssentialFeed
//
//  Created by Hitender Kumar on 09/03/21.
//

import Foundation

// Instead of always passing models across boundaries, consider using a data transfer representation (also known as data transfer objects or DTO).

public struct LocalFeedImage : Equatable {
    public var id : UUID
    public var description : String?
    public var location : String?
    public var url : URL
    
    public init(id: UUID, description: String?, location: String?, url: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.url = url
    }
}
