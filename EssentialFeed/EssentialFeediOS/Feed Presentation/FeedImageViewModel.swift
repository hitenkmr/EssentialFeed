//
//  FeedImageViewModel.swift
//  EssentialFeediOS
//
//  Created by Hitender Kumar on 25/05/21.
//

import Foundation
import EssentialFeed

public struct FeedImageViewModel<Image> {
    let description: String?
    let location: String?
    let image: Image?
    let isLoading: Bool
    let shouldRetry: Bool
    
    var hasLocation: Bool {
        return location != nil
    }
}
