//
//  UIImage+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Hitender Kumar on 24/05/21.
//

import UIKit

extension UIImage {
    //creates a tiny image without overhead of hitting the disk so that tests can be run fast
    static func make(withColor color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)
        context.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}
