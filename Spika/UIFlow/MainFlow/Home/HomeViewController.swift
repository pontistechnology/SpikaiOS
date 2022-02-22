//
//  HomeViewController.swift
//  Spika
//
//  Created by Marko on 06.10.2021..
//

import UIKit

class HomeViewController: UIPageViewController {
    
    var homeTabBar: HomeTabBar!
    var viewModel: HomeViewModel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barStyle = .default
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurePageViewController()
    }
    
    func configurePageViewController() {
        homeTabBar = HomeTabBar(tabBarItems: viewModel.getHomeTabBarItems())
    
        homeTabBar.delegate = self
        
        view.addSubview(homeTabBar)
        homeTabBar.anchor(leading: view.safeAreaLayoutGuide.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.safeAreaLayoutGuide.trailingAnchor)
        homeTabBar.constrainHeight(HomeTabBar.tabBarHeight)
        if let vc = homeTabBar.getViewController(index: 0) {
            self.setViewControllers([vc], direction: .forward, animated: true)
        }
    }
    
    private func switchToController(index: Int) {
        if let vc = homeTabBar.getViewController(index: index) {
            if index < homeTabBar.currentViewControllerIndex {
                setViewControllers([vc], direction: .reverse, animated: true, completion: nil)
            } else {
                setViewControllers([vc], direction: .forward, animated: true, completion: nil)
            }
        }
    }
    
}

extension HomeViewController: HomeTabBarViewDelegate {
    func tabSelected(_ tabBar: HomeTabBar, at index: Int) {
        self.switchToController(index: index)
    }
}
