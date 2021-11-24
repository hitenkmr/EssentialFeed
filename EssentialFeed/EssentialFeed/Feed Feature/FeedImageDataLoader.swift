//
//  Copyright © 2021 Hitender Kumar. All rights reserved.
//

import Foundation

public protocol FeedImageDataLoaderTask {
	func cancel()
}

public protocol FeedImageDataLoader {
    func loadImageData(from url: URL) throws -> Data
}
