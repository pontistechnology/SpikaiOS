//
//  LoginAssembly.swift
//  Spika
//
//  Created by Marko on 27.10.2021..
//

import Foundation
import Swinject

class LoginAssembly: Assembly {
    func assemble(container: Container) {
        assembleEnterNumberViewController(container)
        assembleCountryPickerViewController(container)
        assembleEnterVerifyCodeViewController(container)
        assembleEnterUsernameViewController(container)
    }
    
    private func assembleEnterNumberViewController(_ container: Container) {
        container.register(EnterNumberViewModel.self) { (resolver, coordinator: AppCoordinator) in
            let repository = container.resolve(Repository.self, name: RepositoryType.production.name)!
            return EnterNumberViewModel(repository: repository, coordinator: coordinator)
        }.inObjectScope(.transient)
        
        container.register(EnterNumberViewController.self) { (resolver, coordinator: AppCoordinator) in
            let controller = EnterNumberViewController()
            controller.viewModel = container.resolve(EnterNumberViewModel.self, argument: coordinator)
            return controller
        }.inObjectScope(.transient)
    }
    
    private func assembleEnterUsernameViewController(_ container: Container) {
        container.register(EnterUsernameViewModel.self) { (resolver, coordinator: AppCoordinator) in
            let repository = container.resolve(Repository.self, name: RepositoryType.production.name)!
            return EnterUsernameViewModel(repository: repository, coordinator: coordinator)
        }.inObjectScope(.transient)
        
        container.register(EnterUsernameViewController.self) { (resolver, coordinator: AppCoordinator) in
            let controller = EnterUsernameViewController()
            controller.viewModel = container.resolve(EnterUsernameViewModel.self, argument: coordinator)
            return controller
        }.inObjectScope(.transient)
    }
    
    private func assembleEnterVerifyCodeViewController(_ container: Container) {
        container.register(EnterVerifyCodeViewModel.self) { (resolver, coordinator: AppCoordinator, phoneNumber: TelephoneNumber, deviceId: String) in
            let repository = container.resolve(Repository.self, name: RepositoryType.production.name)!
            return EnterVerifyCodeViewModel(repository: repository, coordinator: coordinator, deviceId: deviceId, phoneNumber: phoneNumber)
        }.inObjectScope(.transient)
        
        container.register(EnterVerifyCodeViewController.self) { (resolver, coordinator: AppCoordinator, number: TelephoneNumber, deviceId: String) in
            let controller = EnterVerifyCodeViewController()
            controller.viewModel = container.resolve(EnterVerifyCodeViewModel.self, arguments: coordinator, number, deviceId)
            return controller
        }.inObjectScope(.transient)
    }
    
    private func assembleCountryPickerViewController(_ container: Container) {
        container.register(CountryPickerViewModel.self) { (resolver, coordinator: AppCoordinator) in
            let repository = container.resolve(Repository.self, name: RepositoryType.production.name)!
            return CountryPickerViewModel(repository: repository, coordinator: coordinator)
        }.inObjectScope(.transient)
        
        container.register(CountryPickerViewController.self) { (resolver, coordinator: AppCoordinator, delegate: CountryPickerViewDelegate) in
            let controller = CountryPickerViewController()
            controller.delegate = delegate
            controller.viewModel = container.resolve(CountryPickerViewModel.self, argument: coordinator)
            return controller
        }.inObjectScope(.transient)
    }
    
}
