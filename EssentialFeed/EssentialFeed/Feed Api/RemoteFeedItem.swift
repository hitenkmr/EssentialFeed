//
//  Copyright © 2021 Hitender Kumar. All rights reserved.
//

import Foundation

struct RemoteFeedItem: Decodable {
	let id: UUID
	let description: String?
	let location: String?
	let image: URL
}
