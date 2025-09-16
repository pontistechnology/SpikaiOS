//
//  HomeTabBar.swift
//  Spika
//
//  Created by Marko on 21.10.2021..
//

import UIKit
import Combine

class HomeTabBar: UIView, BaseView {
    
    private let tabContainer = UIView()
    let tabStackView = UIStackView()
    
    let tabBarItems: [TabBarItem]
    let tabs: [TabBarItemView]
    
    let tabSelectedPublisher = PassthroughSubject<TabBarItem,Never>()
    
    var subscriptions = Set<AnyCancellable>()
    
    static let tabBarHeight: CGFloat = 65.0
    
    init(tabBarItems: [TabBarItem]) {
        self.tabBarItems = tabBarItems
        self.tabs = tabBarItems.map { TabBarItemView(tabBarItem: $0) }
        
        super.init(frame: .zero)
        setupView()
        
        for tab in self.tabs {
            self.tabStackView.addArrangedSubview(tab)
            tab.tabSelectedPublisher
                .subscribe(self.tabSelectedPublisher)
                .store(in: &self.subscriptions)
        }
    }
    
    func updateUnreadChatsCount(_ count: Int) {
        let text = count > 0 ? String(count) : nil
        tabs.first { tab in
            tab.tab == .chat(withChatId: nil)
        }?.updateCountLabel(text)
    }
    
    func updateSelectedTab(selectedTab: TabBarItem) {
        for tab in self.tabs {
            tab.updateIsSelected(isSelected: tab.tab == selectedTab)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        addSubview(tabContainer)
        addSubview(tabStackView)
    }
    
    func styleSubviews() {
        tabStackView.axis = .horizontal
        tabStackView.alignment = .fill
        tabStackView.distribution = .fillEqually
        tabStackView.spacing = 0
    }
    
    func positionSubviews() {
        tabContainer.anchor(leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor)
        tabContainer.constrainHeight(HomeTabBar.tabBarHeight)
        
        tabStackView.anchor(leading: leadingAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15))
        tabStackView.constrainHeight(HomeTabBar.tabBarHeight - 15)
        tabStackView.centerY(inView: tabContainer)
    }
    
}
