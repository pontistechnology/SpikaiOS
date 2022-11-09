//
//  HomeViewController.swift
//  Spika
//
//  Created by Marko on 06.10.2021..
//

import UIKit
import Swinject
import Combine

class HomeViewController: UIPageViewController {
    
//    struct HomeViewControllerStartConfig {
//        let startingTab: Int
//        let startWithMessage: Message?
//        static func defaultConfig() -> HomeViewControllerStartConfig {
//            return HomeViewControllerStartConfig(startingTab: 0, startWithMessage: nil)
//        }
//    }
    
    var homeTabBar: HomeTabBar!
    let viewModel: HomeViewModel
    let startTab: SpikaTabBar
    
    var tabViewControllers: [UIViewController]!

    var subscriptions = Set<AnyCancellable>()
    
    init(viewModel:HomeViewModel, startTab: SpikaTabBar) {
        self.startTab = startTab
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
        setupBinding()
        
//        self.switchToController(index: SpikaTabBar.allTabs().firstIndex(where: <#T##(SpikaTabBar) throws -> Bool#>))
//        if let message = self.startConfig.startWithMessage {
//            self.viewModel.presentChat(message: message)
//        }
    }
    
    func setupBinding() {
        self.viewModel.repository
            .unreadRoomsPublisher
            .sink { value in
                let stringValue = value > 0 ? String(value) : ""
                self.title = stringValue
            }.store(in: &self.subscriptions)
        self.switchToController(tab: self.startTab)
        
        self.viewModel.repository.unreadRoomsPublisher
            .subscribe(self.homeTabBar.unreadRoomsPublisher)
            .store(in: &self.subscriptions)
    }
    
    func configurePageViewController() {
        self.tabViewControllers = SpikaTabBar.allTabs().map { $0.viewControllerForTab(assembler: Assembler.sharedAssembler,
                                                                                      appCoordinator: self.viewModel.getAppCoordinator()!) }
        homeTabBar = HomeTabBar(tabBarItems: SpikaTabBar.allTabs())
        homeTabBar.delegate = self
        
        view.addSubview(homeTabBar)
        homeTabBar.anchor(leading: view.safeAreaLayoutGuide.leadingAnchor,
                          bottom: view.safeAreaLayoutGuide.bottomAnchor,
                          trailing: view.safeAreaLayoutGuide.trailingAnchor)
        homeTabBar.constrainHeight(HomeTabBar.tabBarHeight)
    }
    
    private func switchToController(tab: SpikaTabBar) {
        let newIndex = SpikaTabBar.indexForTab(tab: tab)
        
        var direction: NavigationDirection = .forward
        if let current = self.viewControllers?.first {
            let index = SpikaTabBar.indexOfViewController(viewController: current)
            direction = newIndex > index ? .forward : .reverse
        }
        
        let viewController = self.tabViewControllers[newIndex]
        
        setViewControllers([viewController], direction: direction, animated: true, completion: nil)
        self.homeTabBar.updateSelectedTab(selectedTab: tab)
    }
    
}

extension HomeViewController: HomeTabBarViewDelegate {
    func tabSelected(_ tab: SpikaTabBar) {
        self.switchToController(tab: tab)
    }
}
