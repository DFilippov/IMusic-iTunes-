//
//  Nib.swift
//  IMusic (iTunes)
//
//  Created by Ayu Filippova on 21/10/2019.
//  Copyright © 2019 Dmitry Filippov. All rights reserved.
//

import UIKit

extension UIView {
    class func loadFromNib<T: UIView>() -> T {
        let name = String(describing: T.self)
        let view = Bundle.main.loadNibNamed(name, owner: nil, options: nil)?.first as! T
        return view
    }
}
