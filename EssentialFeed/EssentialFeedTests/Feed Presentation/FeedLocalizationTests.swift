//
//  Copyright © 2021 Hitender Kumar. All rights reserved.
//

import XCTest
import EssentialFeed

final class FeedLocalizationTests: XCTestCase {
	
	func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
		let table = "Feed"
		let presentationBundle = Bundle(for: FeedPresenter.self)
		 
        assertLocalizedKeyAndValuesExist(in: presentationBundle, table)
	}
}
