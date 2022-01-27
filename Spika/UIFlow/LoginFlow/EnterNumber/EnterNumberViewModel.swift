//
//  EnterNumberViewModel.swift
//  Spika
//
//  Created by Marko on 27.10.2021..
//

import Foundation
import Combine

class EnterNumberViewModel: BaseViewModel {
    
    func authenticateWithNumber(number: String, deviceId: String) {
        repository.authenticateUser(telephoneNumber: number, deviceId: deviceId).sink { completion in
            switch completion {
            case let .failure(error):
                print("Could not auth user: \(error)")
            default: break
            }
        } receiveValue: { [weak self] authResponse in
//            print("AUTH Response: ", authResponse)
            self?.presentVerifyCodeScreen(number: number, deviceId: deviceId)
        }.store(in: &subscriptions)

    }
    
    func presentCountryPicker(delegate: CountryPickerViewDelegate) {
        getAppCoordinator()?.presentCountryPicker(delegate: delegate)
    }
    
    func presentVerifyCodeScreen(number: String, deviceId: String) {
        getAppCoordinator()?.presentVerifyCodeScreen(number: number, deviceId: deviceId)
    }
    
}
