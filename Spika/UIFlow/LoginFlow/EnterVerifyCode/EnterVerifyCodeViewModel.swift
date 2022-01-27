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
    let isApiFinishedSuccessfullySubject = CurrentValueSubject<Bool, Never>(false)
    
    init(repository: Repository, coordinator: Coordinator, deviceId: String, phoneNumber: String) {
        self.deviceId = deviceId
        self.phoneNumber = phoneNumber
        super.init(repository: repository, coordinator: coordinator)
    }
    
    func verifyCode(code: String) {
        repository.verifyCode(code: code, deviceId: deviceId).sink { completion in
            switch completion {
            case let .failure(error):
                print("Could not auth user: \(error)")
                self.isApiFinishedSuccessfullySubject.value = false
                
            default: break
            }
        } receiveValue: { [weak self] authModel in
            print("VerifyCodeVM", authModel)
            if authModel.status == "fail" {
                self?.isApiFinishedSuccessfullySubject.value = false
            } else {
                self?.isApiFinishedSuccessfullySubject.value = true
            }
            guard let user = authModel.data?.user,
                  let device = authModel.data?.device
            else { return }
            self?.repository.saveUserInfo(user: user, device: device)
        }.store(in: &subscriptions)

    }
    
    func resendCode() {
        repository.authenticateUser(telephoneNumber: phoneNumber, deviceId: deviceId).sink { completion in
            switch completion {
            case let .failure(error):
                print("Could not auth user: \(error)")
            default: break
            }
        } receiveValue: { [weak self] authResponse in
            self?.resendSubject.value = true
        }.store(in: &subscriptions)
    }
    
}
