//
//  Copyright © 2021 Hitender Kumar. All rights reserved.
//

import Foundation
import Combine

public protocol FeedImageDataStore {
    func insert(_ data: Data, for url: URL) throws
    func retrieve(dataForURL url: URL) throws -> Data?
}
