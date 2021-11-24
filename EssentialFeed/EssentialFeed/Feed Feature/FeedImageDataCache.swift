//
//  Copyright © 2021 Hitender Kumar. All rights reserved.
//

import Foundation

public protocol FeedImageDataCache {
    func save(_ data: Data, for url: URL) throws 
}

