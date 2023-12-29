//
//  TabBarController.swift
//  AppleMusic
//
//  Created by Halil Yavuz on 21.09.2023.
//

import UIKit
import SnapKit

protocol TabBarControllerDelegate: AnyObject {
    func minizeTrackDetail()
    func maximizeTrackDetail(viewModel: SearchCellViewModel.Cell?)
}
class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTabs()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // changeHeightOfTabbar()
    }
    
    private func setupTabs() {
        
        let searchVc = createNav(title: "Library", image: UIImage(systemName: "magnifyingglass"), vc: SearchViewController())
        let libraryVc = createNav(title: "Search", image: UIImage(named: "library"), vc: LibraryViewController())
        
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
    
    
    
    
    //
    
    //    func changeHeightOfTabbar() {
    //
    //        if UIDevice().userInterfaceIdiom == .phone {
    //            var tabFrame = tabBar.frame
    //            tabFrame.size.height = 85
    //            tabFrame.origin.y = view.frame.size.height - 85
    //            tabBar.frame = tabFrame
    //        }
    //    }
}





