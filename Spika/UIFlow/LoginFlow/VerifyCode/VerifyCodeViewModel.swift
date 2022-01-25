//
//  VerifyCodeViewModel.swift
//  Spika
//
//  Created by Marko on 28.10.2021..
//

import Foundation
import Combine

class VerifyCodeViewModel: BaseViewModel {
    
    let deviceId: String
    let phoneNumber: String
    let countryCode: String
    
    let resendSubject = CurrentValueSubject<Bool, Never>(false)
    
    init(repository: Repository, coordinator: Coordinator, deviceId: String, phoneNumber: String, countryCode: String) {
        self.deviceId = deviceId
        self.phoneNumber = phoneNumber
        self.countryCode = countryCode
        super.init(repository: repository, coordinator: coordinator)
    }
    
    func verifyCode(code: String) {
        repository.verifyCode(code: code, deviceId: deviceId).sink { completion in
            switch completion {
            case let .failure(error):
                print("Could not auth user: \(error)")
                
            default: break
            }
        } receiveValue: { [weak self] authModel in
            guard let user = authModel.data?.user,
                  let device = authModel.data?.device
            else { return }
            self?.repository.saveUserInfo(user: user, device: device)
        }.store(in: &subscriptions)

    }
    
    func resendCode() {
        repository.authenticateUser(telephoneNumber: phoneNumber, deviceId: deviceId, countryCode: countryCode).sink { completion in
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
