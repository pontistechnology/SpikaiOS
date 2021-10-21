//
//  HomeViewModel.swift
//  Spika
//
//  Created by Marko on 06.10.2021..
//

import Foundation

class HomeViewModel: BaseViewModel {
    
    func getHomeTabBarItems() -> [TabBarItem] {
        return getAppCoordinator()!.getHomeTabBarItems()
    }
    
}
