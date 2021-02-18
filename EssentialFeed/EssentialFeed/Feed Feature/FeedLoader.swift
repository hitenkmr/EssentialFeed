//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Hitender Kumar on 18/02/21.
//

import Foundation

public enum LoadFeedResult<Error : Swift.Error>{
    case success([FeedItem])
    case failure([Error])
}

//extension LoadFeedResult : Equatable where Error : Equatable {}

protocol FeedLoader {
    associatedtype Error : Swift.Error
    func load(completion : @escaping (LoadFeedResult<Error>) -> Void)
} 
