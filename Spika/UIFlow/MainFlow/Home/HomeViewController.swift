//
//  HomeViewController.swift
//  Spika
//
//  Created by Marko on 06.10.2021..
//

import UIKit
import Combine

class HomeViewController: UIPageViewController {
    
    struct HomeViewControllerStartConfig {
        let startingTab: Int
        let startWithMessage: Message?
        static func defaultConfig() -> HomeViewControllerStartConfig {
            return HomeViewControllerStartConfig(startingTab: 0, startWithMessage: nil)
        }
    }
    
    var homeTabBar: HomeTabBar!
    let viewModel: HomeViewModel
    let startConfig: HomeViewControllerStartConfig

    var subscriptions = Set<AnyCancellable>()
    
    init(viewModel:HomeViewModel, startConfig: HomeViewControllerStartConfig) {
        self.startConfig = startConfig
        self.viewModel = viewModel
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barStyle = .default
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
        viewModel.updatePush()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurePageViewController()
        
        self.viewModel.repository
            .unreadRoomsPublisher
            .sink { value in
                let stringValue = value > 0 ? String(value) : ""
                self.title = stringValue
            }.store(in: &self.subscriptions)
        
        if let message = self.startConfig.startWithMessage {
            self.viewModel.presentChat(message: message)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    func configurePageViewController() {
        homeTabBar = HomeTabBar(tabBarItems: viewModel.getHomeTabBarItems(startingTab: self.startConfig.startingTab))
        homeTabBar.delegate = self
        
        view.addSubview(homeTabBar)
        homeTabBar.anchor(leading: view.safeAreaLayoutGuide.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.safeAreaLayoutGuide.trailingAnchor)
        homeTabBar.constrainHeight(HomeTabBar.tabBarHeight)
        
        if let vc = homeTabBar.getViewController(index: self.startConfig.startingTab) {
            self.setViewControllers([vc], direction: .forward, animated: true)
            self.homeTabBar.tabs.forEach{$0.isSelected = false}
            self.homeTabBar.tabs[self.startConfig.startingTab].isSelected = true
            self.homeTabBar.currentViewControllerIndex = self.startConfig.startingTab
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
