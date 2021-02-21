//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Hitender Kumar on 13/02/21.
//

import Foundation

/**
 By creating a clean seperation with protocols, we made the RemoteFeedLoader more flexible, open for extension and more testable
 
 The HTTPClient does not need to be a class . it is just a contract defining which external functinality the RemoteFeedLoader needs, so a protocol is more suitable way to define it.
 */

public protocol HTTPClient {
    func get(from url : URL, completion : @escaping (HTTPClientResult) -> Void)
}

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}
