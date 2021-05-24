//
//  UIButton+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Hitender Kumar on 24/05/21.
//

import Foundation
import UIKit

extension UIButton {
    func simulateTap() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .touchUpInside)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}
