//
//  HomeViewController.swift
//  Spika
//
//  Created by Marko on 06.10.2021..
//

import UIKit
import Swinject
import Combine
import CoreData

class HomeViewController: UIPageViewController {
    
    var homeTabBar: HomeTabBar!
    let viewModel: HomeViewModel
    let startTab: TabBarItem
    
    var tabViewControllers: [UIViewController]!

    var subscriptions = Set<AnyCancellable>()
    
    init(viewModel:HomeViewModel, startTab: TabBarItem) {
        self.startTab = startTab
        self.viewModel = viewModel
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
        viewModel.frc?.delegate = self
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
        
        self.switchToController(tab: self.startTab)
        
        if case .chat(let roomId) = self.startTab,
           let id = roomId {
            self.viewModel.presentChat(roomId: id)
        }
    }
    
    func setupBinding() {
        self.homeTabBar
            .tabSelectedPublisher
            .sink { [weak self] tab in
                self?.switchToController(tab: tab)
            }.store(in: &self.subscriptions)
    }
    
    func configurePageViewController() {
        self.tabViewControllers = TabBarItem.allTabs().map { $0.viewControllerForTab(assembler: Assembler.sharedAssembler,
                                                                                     appCoordinator: self.viewModel.getAppCoordinator()!) }
        homeTabBar = HomeTabBar(tabBarItems: TabBarItem.allTabs())
        
        view.addSubview(homeTabBar)
        homeTabBar.anchor(leading: view.safeAreaLayoutGuide.leadingAnchor,
                          bottom: view.safeAreaLayoutGuide.bottomAnchor,
                          trailing: view.safeAreaLayoutGuide.trailingAnchor)
        homeTabBar.constrainHeight(HomeTabBar.tabBarHeight)
    }
    
    private func switchToController(tab: TabBarItem) {
        let newIndex = TabBarItem.indexForTab(tab: tab)
        
        var direction: NavigationDirection = .forward
        if let current = self.viewControllers?.first {
            let index = TabBarItem.indexOfViewController(viewController: current)
            direction = newIndex > index ? .forward : .reverse
        }
        
        let viewController = self.tabViewControllers[newIndex]
        
        setViewControllers([viewController], direction: direction, animated: true, completion: nil)
        self.homeTabBar.updateSelectedTab(selectedTab: tab)
    }
    
}

extension HomeViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let count = viewModel.frc?.sections?.first?.numberOfObjects else { return }
        homeTabBar.updateUnreadChatsCount(count)
        navigationItem.backButtonTitle = count > 0 ? String(count) : ""
    }
}
