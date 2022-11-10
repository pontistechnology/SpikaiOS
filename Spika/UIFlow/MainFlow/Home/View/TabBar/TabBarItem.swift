//
//  SpikaTabBar.swift
//  Spika
//
//  Created by Vedran Vugrin on 09.11.2022..
//

import UIKit
import Combine
import Swinject

enum TabBarItem: Equatable {
    case chat(withChatId: Int64?)
    case phoneCalls
    case contacts
    case settings
    
    var title: String {
        switch self {
        case .chat:
            return NSLocalizedString("Chat", comment: "Chat")
        case .phoneCalls:
            return NSLocalizedString("Call History", comment: "Call History")
        case .contacts:
            return NSLocalizedString("Contacts", comment: "Contacts")
        case .settings:
            return NSLocalizedString("Settings", comment: "Settings")
        }
    }
    
    var imageNormal: UIImage {
        switch self {
        case .chat:
            return UIImage(safeImage: .chatsTab)
        case .phoneCalls:
            return UIImage(safeImage: .callHistoryTab)
        case .contacts:
            return UIImage(safeImage: .contactsTab)
        case .settings:
            return UIImage(safeImage: .settingsTab)
        }
    }
    
    var imageSelected: UIImage {
        switch self {
        case .chat:
            return UIImage(safeImage: .chatsTabFull)
        case .phoneCalls:
            return UIImage(safeImage: .callHistoryTabFull)
        case .contacts:
            return UIImage(safeImage: .contactsTabFull)
        case .settings:
            return UIImage(safeImage: .settingsTabFull)
        }
    }
    
    static func allTabs() -> [TabBarItem] {
        return [.chat(withChatId: nil), .phoneCalls, .contacts, .settings]
    }
    
    func viewControllerForTab(assembler: Assembler, appCoordinator: AppCoordinator) -> UIViewController {
        switch self {
        case .chat:
            return assembler.resolver.resolve(AllChatsViewController.self, argument: appCoordinator)!
        case .phoneCalls:
            return  assembler.resolver.resolve(CallHistoryViewController.self, argument: appCoordinator)!
        case .contacts:
            return assembler.resolver.resolve(ContactsViewController.self, argument: appCoordinator)!
        case .settings:
            return assembler.resolver.resolve(SettingsViewController.self, argument: appCoordinator)!
        }
    }
    
    private func classForTab() -> AnyClass {
        switch self {
        case .chat:
            return AllChatsViewController.self
        case .phoneCalls:
            return  CallHistoryViewController.self
        case .contacts:
            return ContactsViewController.self
        case .settings:
            return SettingsViewController.self
        }
    }
    
    static func indexForTab(tab: TabBarItem) -> Int {
        return TabBarItem.allTabs().firstIndex(of: tab) ?? 0
    }
    
    static func indexOfViewController(viewController: UIViewController) -> Int {
        let allTabs = TabBarItem.allTabs()
        
        return allTabs.firstIndex { tab in
            viewController.isKind(of: tab.classForTab())
        } ?? 0
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        if case .chat = lhs, case .chat = rhs {
            return true
        }
        if case .phoneCalls = lhs, case .phoneCalls = rhs {
            return true
        }
        if case .contacts = lhs, case .contacts = rhs {
            return true
        }
        if case .settings = lhs, case .settings = rhs {
            return true
        }
        return false
    }
    
}
