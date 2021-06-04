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

public protocol HTTPClientTask {
    func cancel()
}

public protocol HTTPClient {
    
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    
    ///The completion handler can be invoked in any thread(main thread if to update the UI OR background thread if some non-UI work needs to be done).
    ///Clients are responsible to dispatch to appropriate threah, if needed.
    @discardableResult
    func get(from url: URL, completion: @escaping (Result) -> Void) -> HTTPClientTask
}
