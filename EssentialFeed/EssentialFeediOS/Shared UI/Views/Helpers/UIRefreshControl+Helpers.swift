//
//  Copyright © 2021 Hitender Kumar. All rights reserved.
//

import UIKit

extension UIRefreshControl {
	func update(isRefreshing: Bool) {
		isRefreshing ? beginRefreshing() : endRefreshing()
	}
}
