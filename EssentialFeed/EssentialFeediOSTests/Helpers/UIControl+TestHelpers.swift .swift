//
//  UIControl+TestHelpers.swift .swift
//  EssentialFeediOSTests
//
//  Created by Hitender Kumar on 24/05/21.
//

import Foundation
import UIKit

extension UIControl {
    func simulate(event: UIControl.Event) {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: event)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}
