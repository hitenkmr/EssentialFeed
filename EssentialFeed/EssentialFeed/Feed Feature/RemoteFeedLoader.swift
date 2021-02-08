//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Mac Book on 07/02/21.
//

import Foundation

/**
 The RemoteFeedLoader does not need to locate or instantiate HTTPClient instance. Instead we can make our code more modular by injecting HTTPClient as a dependency.
 */
class RemoteFeedLoader {
    
    let client : HTTPClient
    let url : URL
    
    init(url : URL, client : HTTPClient) {
        self.client = client
        self.url = url
    }
    
    func load() {
        client.getFeed(url: url)
    }
}

/**
 By creating a clean seperation with protocols, we made the RemoteFeedLoader more flexible, open for extension and more testable
 
The HTTPClient does not need to be a class . it is just a contract defining which external functinality the RemoteFeedLoader needs, so a protocol is more suitable way to define it.
*/

protocol HTTPClient {
    func getFeed(url : URL)
}
