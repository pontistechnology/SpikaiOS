//
//  SpikaTabBar.swift
//  Spika
//
//  Created by Vedran Vugrin on 09.11.2022..
//

import UIKit
import Combine
import Swinject

enum SpikaTabBar: Equatable {
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
    
    var image: UIImage {
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
    
    static func allTabs() -> [SpikaTabBar] {
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
    
    func classForTab() -> AnyClass {
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
    
    static func indexForTab(tab: SpikaTabBar) -> Int {
        return SpikaTabBar.allTabs().firstIndex(of: tab) ?? 0
    }
    
    static func indexOfViewController(viewController: UIViewController) -> Int {
        let allTabs = SpikaTabBar.allTabs()
        
        return allTabs.firstIndex { tab in
            viewController.isKind(of: tab.classForTab())
        } ?? 0
    }
    
}
