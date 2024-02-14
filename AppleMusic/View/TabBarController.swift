//
//  TabBarController.swift
//  AppleMusic
//
//  Created by Halil Yavuz on 21.09.2023.
//

import UIKit
import SnapKit
import CoreData

final class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTabs()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // changeHeightOfTabbar()
    }
    
    private func setupTabs() {
        
        let searchVc = createNav(title: "Поиск", image: UIImage(systemName: "magnifyingglass"), vc: SearchViewController())
        let libraryVc = createNav(title: "Медиатека", image: UIImage(named: "library"), vc: LibraryViewController())
        
        setViewControllers([searchVc,libraryVc], animated: true)
        
        tabBar.tintColor = .systemRed
        tabBar.barTintColor = .black
        
    }
    
    private func createNav(title: String, image: UIImage?, vc: UIViewController) -> UINavigationController {
        let nav = UINavigationController(rootViewController: vc)
        nav.title = title
        nav.tabBarItem.image = image
        return nav
    }
    
}


