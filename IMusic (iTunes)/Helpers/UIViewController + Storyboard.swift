//
//  UIViewController + Storyboard.swift
//  IMusic (iTunes)
//
//  Created by Ayu Filippova on 10/10/2019.
//  Copyright © 2019 Dmitry Filippov. All rights reserved.
//

import UIKit

extension UIViewController {
    
    class func loadFromStoryboard<T: UIViewController>() -> T {
        let name = String(describing: T.self)
        let storyboard = UIStoryboard(name: name, bundle: nil)
        if let viewController = storyboard.instantiateInitialViewController() as? T {
            
            return viewController
        } else {
            fatalError("Error: No initail view controller in \(name) stroryboard")
        }
        
    }
    
}
