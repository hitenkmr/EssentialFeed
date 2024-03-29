//
//  Copyright © 2021 Hitender Kumar. All rights reserved.
//

import Foundation

public protocol FeedCache {
	typealias Result = Swift.Result<Void, Error>

	func save(_ feed: [FeedImage], completion: @escaping (Result) -> Void)
}
