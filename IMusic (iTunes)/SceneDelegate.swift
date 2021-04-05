//
//  SceneDelegate.swift
//  IMusic (iTunes)
//
//  Created by Ayu Filippova on 06/10/2019.
//  Copyright © 2019 Dmitry Filippov. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        window?.makeKeyAndVisible()
        window?.rootViewController = MainTabBarController()

    }

}

