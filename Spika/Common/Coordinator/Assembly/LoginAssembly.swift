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
        assembleVerifyCodeViewController(container)
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
    
    private func assembleVerifyCodeViewController(_ container: Container) {
        container.register(VerifyCodeViewModel.self) { (resolver, coordinator: AppCoordinator, number: String, deviceId: String, countryCode: String) in
            let repository = container.resolve(Repository.self, name: RepositoryType.production.name)!
            return VerifyCodeViewModel(repository: repository, coordinator: coordinator, deviceId: deviceId, phoneNumber: number, countryCode: countryCode)
        }.inObjectScope(.transient)
        
        container.register(VerifyCodeViewController.self) { (resolver, coordinator: AppCoordinator, number: String, deviceId: String, countryCode: String) in
            let controller = VerifyCodeViewController()
            controller.viewModel = container.resolve(VerifyCodeViewModel.self, arguments: coordinator, number, deviceId, countryCode)
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
