//
//  EnterNumberViewModel.swift
//  Spika
//
//  Created by Marko on 27.10.2021..
//

import Foundation
import Combine

class EnterNumberViewModel: BaseViewModel {
    
    func authenticateWithNumber(telephoneNumber: TelephoneNumber, deviceId: String) {
        networkRequestState.send(.started())
        repository.authenticateUser(telephoneNumber: telephoneNumber.getFullNumber(), deviceId: deviceId).sink { [weak self] completion in
            self?.networkRequestState.send(.finished)
            switch completion {
            case let .failure(error):
                self?.showError("\(Constants.Strings.couldNotAuthUser): \(error)")
            default: break
            }
        } receiveValue: { [weak self] authResponse in
            self?.presentEnterVerifyCodeScreen(telephoneNumber: telephoneNumber, deviceId: deviceId)
        }.store(in: &subscriptions)

    }
    
    func checkIfUserWasLogged() -> (phoneNumber: TelephoneNumber, deviceId: String)? {
        guard let telephoneNumber = repository.getMyTelephoneNumber(),
              let deviceId = repository.getMyDeviceId()
        else {
            return nil
        }
        return (telephoneNumber, deviceId)
    }
    
    func presentCountryPicker(delegate: CountryPickerViewDelegate) {
        getAppCoordinator()?.presentCountryPicker(delegate: delegate)
    }
    
    func presentEnterVerifyCodeScreen(telephoneNumber: TelephoneNumber, deviceId: String) {
        getAppCoordinator()?.presentEnterVerifyCodeScreen(number: telephoneNumber, deviceId: deviceId)
    }
    
}
