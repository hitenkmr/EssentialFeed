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
        simulate(event: .touchUpInside)
    }
}
