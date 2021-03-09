//
//  LocalFeedItem.swift
//  EssentialFeed
//
//  Created by Hitender Kumar on 09/03/21.
//

import Foundation

public struct LocalFeedImage : Equatable {
    var id : UUID
    var description : String?
    var location : String?
    var url : URL
}
