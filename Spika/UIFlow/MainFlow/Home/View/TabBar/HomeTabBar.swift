//
//  HomeTabBar.swift
//  Spika
//
//  Created by Marko on 21.10.2021..
//

import UIKit

protocol HomeTabBarViewDelegate: AnyObject {
    func tabSelected(_ tabBar: HomeTabBar, at index: Int)
}

class HomeTabBar: UIView, BaseView {
    
    private let tabContainer = UIView()
    let tabStackView = UIStackView()
    private let topBorderView  = UIView()
    var tabBarItems: [TabBarItem]
    var currentViewControllerIndex: Int = 0
    static let tabBarHeight: CGFloat = 65.0
    
    weak var delegate: HomeTabBarViewDelegate?
    
    lazy var tabs: [StackItemView] = {
        var items = [StackItemView]()
        for _ in 0..<tabBarItems.count {
            items.append(StackItemView.newInstance)
        }
        return items
    }()
    
    init(tabBarItems: [TabBarItem]) {
        self.tabBarItems = tabBarItems
        super.init(frame: .zero)
        setupView()
        self.setupTabs()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupTabs() {
        for i in 0..<self.tabBarItems.count {
            let tabView = self.tabs[i]
            self.tabBarItems[i].isSelected = i == 0
            tabView.item = self.tabBarItems[i]
            tabView.delegate = self
            self.tabStackView.addArrangedSubview(tabView)
        }
    }
    
    func addSubviews() {
        addSubview(tabContainer)
        addSubview(tabStackView)
        addSubview(topBorderView)
    }
    
    func styleSubviews() {
        tabContainer.backgroundColor = .whiteAndDarkBackground
        
        tabStackView.axis = .horizontal
        tabStackView.alignment = .fill
        tabStackView.contentMode = .scaleToFill
        tabStackView.distribution = .equalSpacing
        tabStackView.spacing = 0
        tabStackView.layer.cornerRadius = 30
        
        topBorderView.backgroundColor = .lightGray.withAlphaComponent(0.5)
    }
    
    func positionSubviews() {
        tabContainer.anchor(leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor)
        tabContainer.constrainHeight(HomeTabBar.tabBarHeight)
        
        tabStackView.anchor(leading: leadingAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 10, left: 35, bottom: 10, right: 35))
        tabStackView.constrainHeight(HomeTabBar.tabBarHeight - 15)
        tabStackView.centerY(inView: tabContainer)
        
        topBorderView.anchor(leading: tabContainer.leadingAnchor, bottom: tabContainer.topAnchor, trailing: tabContainer.trailingAnchor)
        topBorderView.constrainHeight(1)
    }
    
    private func getViewControllersIndex(_ viewController: BaseViewController?) -> Int? {
        if viewController == nil { return nil }
        for i in 0..<tabBarItems.count {
            if tabBarItems[i].viewController == viewController {
                return tabBarItems[i].position
            }
        }
        return nil
    }
    
    func getViewController(index: Int) -> UIViewController? {
        if index < 0 || index >= tabBarItems.count { return nil }
        return self.tabBarItems[index].viewController
    }
    
    func switchToPrevious(currentViewController: UIViewController) -> UIViewController? {
        guard var index = getViewControllersIndex(currentViewController as? BaseViewController) else { return nil}
        self.currentViewControllerIndex = index
        if index == 0 { return nil }
        index -= 1
        return tabBarItems[index].viewController
    }
    
    func switchToNext(currentViewController: UIViewController) -> UIViewController? {
        guard var index = getViewControllersIndex(currentViewController as? BaseViewController) else { return nil}
        self.currentViewControllerIndex = index
        if index == tabBarItems.count - 1 { return nil }
        index += 1
        return tabBarItems[index].viewController
    }
    
    func selectViewController(_ currentViewController: UIViewController) {
        guard let index = getViewControllersIndex(currentViewController as? BaseViewController) else { return }
        self.tabs.forEach{$0.isSelected = false}
        self.tabs[index].isSelected = true
    }
    
}

extension HomeTabBar: StackItemViewDelegate {
    
    func handleTap(_ view: StackItemView) {
        self.tabs.forEach{$0.isSelected = false}
        view.isSelected = true
        delegate?.tabSelected(self, at: (view.item as! TabBarItem).position)
        self.currentViewControllerIndex = self.tabs.firstIndex(where: { $0 === view }) ?? 0
    }
    
}
