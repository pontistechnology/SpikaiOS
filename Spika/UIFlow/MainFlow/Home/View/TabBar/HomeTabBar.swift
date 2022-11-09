//
//  HomeTabBar.swift
//  Spika
//
//  Created by Marko on 21.10.2021..
//

import UIKit
import Combine

protocol HomeTabBarViewDelegate: AnyObject {
    func tabSelected(_ tab: SpikaTabBar)
}

class HomeTabBar: UIView, BaseView {
    
    private let tabContainer = UIView()
    let tabStackView = UIStackView()
    private let topBorderView  = UIView()
    
    let tabBarItems: [SpikaTabBar]
    let tabs: [TabBarItemView]
    
    var unreadRoomsPublisher = PassthroughSubject<Int,Never>()
    
    var subscriptions = Set<AnyCancellable>()
    
    var currentViewControllerIndex: Int = 0
    static let tabBarHeight: CGFloat = 65.0
    
    weak var delegate: HomeTabBarViewDelegate?
    
    init(tabBarItems: [SpikaTabBar]) {
        self.tabBarItems = tabBarItems
        self.tabs = tabBarItems.map { TabBarItemView(tabBarItem: $0) }
        
        super.init(frame: .zero)
        setupView()
        
        for tab in self.tabs {
            self.tabStackView.addArrangedSubview(tab)
            tab.button.publisher(for: .touchUpInside)
                .sink { _ in
                    self.delegate?.tabSelected(tab.tab)
                }.store(in: &self.subscriptions)
        }
        
        self.unreadRoomsPublisher
            .sink { unreadRooms in
                let message = unreadRooms > 0 ? String(unreadRooms) : nil
                self.tabs.first { tab in
                    tab.tab == .chat(withChatId: nil)
                }?.updateMessage(message: message)
            }.store(in: &self.subscriptions)
    }
    
    func updateSelectedTab(selectedTab: SpikaTabBar) {
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
        addSubview(topBorderView)
    }
    
    func styleSubviews() {
        tabContainer.backgroundColor = .whiteAndDarkBackground
        tabStackView.axis = .horizontal
        tabStackView.alignment = .fill
        tabStackView.distribution = .fillEqually
        tabStackView.spacing = 0
        topBorderView.backgroundColor = .lightGray.withAlphaComponent(0.5)
    }
    
    func positionSubviews() {
        tabContainer.anchor(leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor)
        tabContainer.constrainHeight(HomeTabBar.tabBarHeight)
        
        tabStackView.anchor(leading: leadingAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15))
        tabStackView.constrainHeight(HomeTabBar.tabBarHeight - 15)
        tabStackView.centerY(inView: tabContainer)
        
        topBorderView.anchor(leading: tabContainer.leadingAnchor, bottom: tabContainer.topAnchor, trailing: tabContainer.trailingAnchor)
        topBorderView.constrainHeight(1)
    }
    
}
