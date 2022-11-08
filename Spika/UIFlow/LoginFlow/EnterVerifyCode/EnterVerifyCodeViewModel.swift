//
//  EnterVerifyCodeViewModel.swift
//  Spika
//
//  Created by Marko on 28.10.2021..
//

import Foundation
import Combine

class EnterVerifyCodeViewModel: BaseViewModel {
    
    let deviceId: String
    let phoneNumber: String
    
    let resendSubject = CurrentValueSubject<Bool, Never>(false)
    
    init(repository: Repository, coordinator: Coordinator, deviceId: String, phoneNumber: String) {
        self.deviceId = deviceId
        self.phoneNumber = phoneNumber
        super.init(repository: repository, coordinator: coordinator)
    }
    
    func verifyCode(code: String) {
        networkRequestState.send(.started())
        repository.verifyCode(code: code, deviceId: deviceId).sink { [weak self] completion in
            guard let self = self else { return }
            self.networkRequestState.send(.finished)
            switch completion {
            case let .failure(error):
                self.showError("Could not auth user: \(error)")
            default: break
            }
        } receiveValue: { [weak self] authModel in
            print(authModel)
            guard let user = authModel.data?.user,
                  let device = authModel.data?.device
            else {
                self?.showError("No user or device response.")
                return
            }
            self?.repository.saveUserInfo(user: user, device: device)
            if user.displayName != "" {
                self?.presentHomeScreen()
            } else {
                self?.presentEnterUsernameScreen()
            }
        }.store(in: &subscriptions)

    }
    
    func resendCode() {
        networkRequestState.send(.started())
        repository.authenticateUser(telephoneNumber: phoneNumber, deviceId: deviceId).sink { [weak self] completion in
            self?.networkRequestState.send(.finished)
            switch completion {
            case let .failure(error):
                self?.showError("Could not auth user: \(error)")
            default: break
            }
        } receiveValue: { [weak self] authResponse in
            self?.resendSubject.value = true
        }.store(in: &subscriptions)
    }
    
    private func presentEnterUsernameScreen() {
        getAppCoordinator()?.presentEnterUsernameScreen()
    }
    
    private func presentHomeScreen() {
        getAppCoordinator()?.presentHomeScreen(startSyncAndSSE: true)
    }
    
}
