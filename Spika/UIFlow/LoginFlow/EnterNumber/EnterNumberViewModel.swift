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
        networkRequestState.send(.started)
        repository.authenticateUser(telephoneNumber: number, deviceId: deviceId).sink { [weak self] completion in
            self?.networkRequestState.send(.finished)
            switch completion {
            case let .failure(error):
                PopUpManager.shared.presentAlert(errorMessage: "Could not auth user: \(error)")
                print(error)
            default: break
            }
        } receiveValue: { [weak self] authResponse in
            print("AUTH Response: ", authResponse)
            self?.presentEnterVerifyCodeScreen(number: number, deviceId: deviceId)
        }.store(in: &subscriptions)

    }
    
    func presentCountryPicker(delegate: CountryPickerViewDelegate) {
        getAppCoordinator()?.presentCountryPicker(delegate: delegate)
    }
    
    func presentEnterVerifyCodeScreen(number: String, deviceId: String) {
        getAppCoordinator()?.presentEnterVerifyCodeScreen(number: number, deviceId: deviceId)
    }
    
}
