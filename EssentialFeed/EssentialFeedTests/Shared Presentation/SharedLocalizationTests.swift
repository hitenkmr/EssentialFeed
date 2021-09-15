//	
// Copyright © 2021 Hitender Hitender. All rights reserved.
//

import XCTest
import EssentialFeed

class SharedLocalizationTests: XCTestCase {
    
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "Shared"
        let presentationBundle = Bundle(for: LoadResourcePresenter<Any, DummyView>.self)
        assertLocalizedKeyAndValuesExist(in: presentationBundle, table)
    }
    
    class DummyView: ResourceView {
        func display(_ viewModel: Any) { }
    }
  }
