//	
// Copyright © 2021 Hitender Kumar. All rights reserved.
//

import XCTest
import EssentialFeed

class ImageCommentsLocalizationTests: XCTestCase {
 
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "ImageComments"
        let presentationBundle = Bundle(for: ImageCommentsPresenter.self)
         
        assertLocalizedKeyAndValuesExist(in: presentationBundle, table)
    }
}
