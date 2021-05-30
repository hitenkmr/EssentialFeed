//
//  UitableView+Additions.swift
//  EssentialFeediOS
//
//  Created by Hitender Kumar on 30/05/21.
//

import UIKit

extension UITableView {
    
    func dequeueReusableCell<T: UITableViewCell>() -> T {
        let identifier = String(describing: T.self)
        return dequeueReusableCell(withIdentifier: identifier) as! T
    }
}
