//
//  MainTabBarController.swift
//  IMusic (iTunes)
//
//  Created by Ayu Filippova on 06/10/2019.
//  Copyright © 2019 Dmitry Filippov. All rights reserved.
//

import UIKit
import SwiftUI

protocol MainTabBarControllerDelegate: class {
    func minimizeTrackDetailView()
    func maximizeTrackDetailView(viewModel: SearchViewModel.Cell?)
}

class MainTabBarController: UITabBarController {

    private var minimizedTopAnchorConstraint: NSLayoutConstraint!
    private var maximizedTopAnchorConstraint: NSLayoutConstraint!
    private var bottomAnchorConstraint: NSLayoutConstraint!
    
    let searchVC: SearchViewController = SearchViewController.loadFromStoryboard()
    let trackDetailView: TrackDetailView = TrackDetailView.loadFromNib()
        
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        
        tabBar.tintColor = #colorLiteral(red: 0.8549019694, green: 0.080293156, blue: 0.3189237966, alpha: 1)
        
        setupTrackDetailView()
        
        var library = Library()
        library.tabBarDelegate = self
        let hostVC = UIHostingController(rootView: library)
        
        hostVC.tabBarItem.image = #imageLiteral(resourceName: "library")
        hostVC.tabBarItem.title = "Library"
        
        viewControllers = [
            hostVC,
            generateViewController(rootViewController: searchVC, image: #imageLiteral(resourceName: "search"), title: "Search")
        ]
    }
    
    private func generateViewController(rootViewController: UIViewController, image: UIImage, title: String) -> UIViewController{
        let navigationVC = UINavigationController(rootViewController: rootViewController)
        navigationVC.tabBarItem.image = image
        navigationVC.tabBarItem.title = title
        rootViewController.navigationItem.title = title
        navigationVC.navigationBar.prefersLargeTitles = true
        return navigationVC
    }
    

    private func setupTrackDetailView() {
        
        trackDetailView.tabBarDelegate = self
        trackDetailView.delegate = searchVC
        searchVC.tabBarDelegate = self
        view.insertSubview(trackDetailView, belowSubview: tabBar)
        
        // using auto layout
        trackDetailView.translatesAutoresizingMaskIntoConstraints = false
        
        maximizedTopAnchorConstraint = trackDetailView.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height)
        minimizedTopAnchorConstraint = trackDetailView.topAnchor.constraint(equalTo: tabBar.topAnchor, constant: -64)
        bottomAnchorConstraint = trackDetailView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: view.frame.height)

        maximizedTopAnchorConstraint.isActive = true
        bottomAnchorConstraint.isActive = true
        
        trackDetailView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        trackDetailView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true

    }
}

//MARK: -MainTabBarControllerDelegate
extension MainTabBarController: MainTabBarControllerDelegate {
    func maximizeTrackDetailView(viewModel: SearchViewModel.Cell?) {
        
        trackDetailView.miniTrackView.alpha = 0
        trackDetailView.maximizedStackView.alpha = 1
        
        maximizedTopAnchorConstraint.constant = 0
        minimizedTopAnchorConstraint.isActive = false
        maximizedTopAnchorConstraint.isActive = true
        bottomAnchorConstraint.constant = 0
        
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 1,
            options: .curveEaseOut,
            animations: {
                self.view.layoutIfNeeded()
                self.tabBar.alpha = 0
            },
            completion: nil)
        
        guard let model = viewModel else { return }
        trackDetailView.set(viewModel: model)
    }

    
    func minimizeTrackDetailView() {
        
        trackDetailView.miniTrackView.alpha = 1
        trackDetailView.maximizedStackView.alpha = 0
        
        maximizedTopAnchorConstraint.isActive = false
        bottomAnchorConstraint.constant = view.frame.height
        minimizedTopAnchorConstraint.isActive = true
        
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 1,
                       options: .curveEaseOut,
                       animations: {
                        self.tabBar.transform = .identity
                        self.view.layoutIfNeeded()
                        self.tabBar.alpha = 1
                       },
                       completion: nil)
    }
}
