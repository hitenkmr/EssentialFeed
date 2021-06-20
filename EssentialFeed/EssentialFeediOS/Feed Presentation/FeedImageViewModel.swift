//
//  FeedImageViewModel.swift
//  EssentialFeediOS
//
//  Created by Hitender Kumar on 25/05/21.
//

import Foundation
import EssentialFeed

public struct FeedImageViewModel<Image> {
    
    public init(description: String?, location: String?, image: Image?, isLoading: Bool, shouldRetry: Bool) {
        self.description = description
        self.location = location
        self.image = image
        self.isLoading = isLoading
        self.shouldRetry = shouldRetry
    }
    
    public let description: String?
    public let location: String?
    public let image: Image?
    public let isLoading: Bool
    public let shouldRetry: Bool
    
    public var hasLocation: Bool {
        return location != nil
    }
}
