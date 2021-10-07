//
//  AppAssembly.swift
//  Spika
//
//  Created by Marko on 06.10.2021..
//

import Foundation
import Swinject

final class AppAssembly: Assembly {
    
    func assemble(container: Container) {
        self.assembleMainRepository(container)
        self.assembleHomeViewController(container)
    }
    
    private func assembleMainRepository(_ container: Container) {

        container.register(NetworkService.self) { r in
            return NetworkService()
        }.inObjectScope(.container)

        container.register(AppRepository.self) { r in
            return AppRepository(networkService: container.resolve(NetworkService.self)!)
        }.inObjectScope(.container)
    }
    
    private func assembleHomeViewController(_ container: Container) {
        container.register(HomeViewModel.self) { (resolver, coordinator: AppCoordinator) in
            return HomeViewModel(repository: container.resolve(AppRepository.self)!, coordinator: coordinator)
        }.inObjectScope(.transient)
        
        container.register(HomeViewController.self) { (resolver, coordinator: AppCoordinator) in
            let controller = HomeViewController()
            controller.viewModel = container.resolve(HomeViewModel.self, argument: coordinator)
            return controller
        }.inObjectScope(.transient)
    }
    
}
