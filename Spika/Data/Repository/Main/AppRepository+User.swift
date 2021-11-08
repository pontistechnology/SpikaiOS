//
//  AppRepository+User.swift
//  Spika
//
//  Created by Marko on 13.10.2021..
//

import Foundation
import Combine
import CryptoKit

extension AppRepository {
    
    func authenticateUser(telephoneNumber: String, deviceId: String, countryCode: String) -> AnyPublisher<AuthResponseModel, Error> {
        print(telephoneNumber.getSHA256())
        let resources = Resources<AuthResponseModel, AuthRequestModel>(
            path: Constants.Endpoints.authenticateUser,
            requestType: .POST,
            bodyParameters: AuthRequestModel(
                telephoneNumber: telephoneNumber,
                telephoneNumberHashed: telephoneNumber.getSHA256(),
                deviceId: deviceId,
                countryCode: countryCode),
            httpHeaderFields: nil,
            queryParameters: nil
        )
        return networkService.performRequest(resources: resources)
    }
    
    func verifyCode(code: String, deviceId: String) -> AnyPublisher<AuthResponseModel, Error> {
        let resources = Resources<AuthResponseModel, VerifyCodeRequest>(
            path: Constants.Endpoints.verifyCode,
            requestType: .POST,
            bodyParameters: VerifyCodeRequest(code: code, deviceId: deviceId),
            httpHeaderFields: nil,
            queryParameters: nil
        )
        return networkService.performRequest(resources: resources)
    }
    
    func saveUserInfo(user: AppUser, device: Device) {
        let defaults = UserDefaults.standard
        defaults.set(user.id, forKey: Constants.UserDefaults.userId)
        defaults.set(user.telephoneNumber, forKey: Constants.UserDefaults.userPhoneNumber)
        defaults.set(device.deviceId, forKey: Constants.UserDefaults.deviceId)
        defaults.set(device.token, forKey: Constants.UserDefaults.token)
    }
    
    func getUsers() -> Future<[User], Error> {
        return databaseService.userEntityService.getUsers()
    }
    
    func saveUser(_ user: User) -> Future<User, Error> {
        return databaseService.userEntityService.saveUser(user)
    }
    
}
