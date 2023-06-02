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
    
    // MARK: UserDefaults
    
    func saveUserInfo(user: User, device: Device? = nil, telephoneNumber: TelephoneNumber?) {
        userDefaults.set(user.id, forKey: Constants.Database.userId)
        userDefaults.set(user.displayName, forKey: Constants.Database.displayName)
        if let device {
            userDefaults.set(device.id, forKey: Constants.Database.deviceId)
            userDefaults.set(device.token, forKey: Constants.Database.accessToken)
        }
        if let telephoneNumber {
            userDefaults.set(telephoneNumber.countryCode, forKey: Constants.Database.userPhoneNumberCountryCode)
            userDefaults.set(telephoneNumber.restOfNumber, forKey: Constants.Database.userPhoneNumberRest)
        }
    }
    
    func getMyUserId() -> Int64 {
        return Int64(userDefaults.integer(forKey: Constants.Database.userId))
    }
    
    func getMyTelephoneNumber() -> TelephoneNumber? {
        guard let phoneCode = userDefaults.string(forKey: Constants.Database.userPhoneNumberCountryCode),
              let restOfNumber = userDefaults.string(forKey: Constants.Database.userPhoneNumberRest)
        else {
            return nil
        }
        return TelephoneNumber(countryCode: phoneCode, restOfNumber: restOfNumber)
    }
    
    // MARK: Network
    
    func fetchMyUserDetails() -> AnyPublisher<AuthResponseModel, Error> {
        guard let accessToken = getAccessToken()
        else { return Fail<AuthResponseModel, Error>(error: NetworkError.noAccessToken)
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
        let resources = Resources<AuthResponseModel, EmptyRequestBody>(
            path: Constants.Endpoints.getUserDetails,
            requestType: .GET,
            bodyParameters: nil,
            httpHeaderFields: ["accesstoken" : accessToken],
            queryParameters: nil
        )
        return networkService.performRequest(resources: resources)
    }
    
    func authenticateUser(telephoneNumber: String, deviceId: String) -> AnyPublisher<AuthResponseModel, Error> {
        let resources = Resources<AuthResponseModel, AuthRequestModel>(
            path: Constants.Endpoints.authenticateUser,
            requestType: .POST,
            bodyParameters: AuthRequestModel(
                telephoneNumber: telephoneNumber,
                telephoneNumberHashed: telephoneNumber.getSHA256(),
                deviceId: deviceId),
            httpHeaderFields: nil,
            queryParameters: nil
        )
        return networkService.performRequest(resources: resources)
    }
    
    func verifyCode(code: String, deviceId: String) -> AnyPublisher<AuthResponseModel, Error> {
        let resources = Resources<AuthResponseModel, VerifyCodeRequestModel>(
            path: Constants.Endpoints.verifyCode,
            requestType: .POST,
            bodyParameters: VerifyCodeRequestModel(code: code, deviceId: deviceId),
            httpHeaderFields: nil,
            queryParameters: nil
        )
        print("resources are: ", resources)
        return networkService.performRequest(resources: resources)
    }
    
    func updateUser(username: String?, avatarFileId: Int64?, telephoneNumber: String?, email: String?) -> AnyPublisher<UserResponseModel, Error>{
        
        guard let accessToken = getAccessToken()
        else {return Fail<UserResponseModel, Error>(error: NetworkError.noAccessToken)
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
        let resources = Resources<UserResponseModel, UserRequestModel>(
            path: Constants.Endpoints.userInfo,
            requestType: .PUT,
            bodyParameters: UserRequestModel(telephoneNumber: telephoneNumber, emailAddress: email, displayName: username, avatarFileId: avatarFileId),
            httpHeaderFields: ["accesstoken" : accessToken])
        return networkService.performRequest(resources: resources)
    }
    
    func postContacts(hashes: [String], lastPage: Bool) -> AnyPublisher<ContactsResponseModel, Error> {
        guard let accessToken = getAccessToken()
        else { return Fail<ContactsResponseModel, Error>(error: NetworkError.noAccessToken)
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
        let contacts = ContactsRequestModel(contacts: hashes, isLastPage: lastPage)
        let resources = Resources<ContactsResponseModel, ContactsRequestModel>(
            path: Constants.Endpoints.contacts,
            requestType: .POST,
            bodyParameters: contacts,
            httpHeaderFields: ["accesstoken" : accessToken])
        return networkService.performRequest(resources: resources)
    }
    
    func getContacts(page: Int) -> AnyPublisher<ContactsResponseModel, Error> {
        guard let accessToken = getAccessToken()
        else { return Fail<ContactsResponseModel, Error>(error: NetworkError.noAccessToken)
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
        let resources = Resources<ContactsResponseModel, EmptyRequestBody>(
            path: Constants.Endpoints.contacts,
            requestType: .GET,
            bodyParameters: nil,
            httpHeaderFields: ["accesstoken" : accessToken],
            queryParameters: ["page": String(page)]
        )
        return networkService.performRequest(resources: resources)
    }
    
    // MARK: Database
    
    func getLocalUsers() -> Future<[User], Error> {
        return databaseService.getLocalUsers()
    }
    
    func getLocalUser(withId id: Int64) -> Future<User, Error> {
        return databaseService.getLocalUser(withId: id)
    }
    
    func saveUsers(_ users: [User]) -> Future<[User], Error> {
        return databaseService.saveUsers(users)
    }
    
    func saveContacts(_ contacts: [FetchedContact]) -> Future<[FetchedContact], Error> {
        return databaseService.saveContacts(contacts)
    }
    
    func updateUsersWithContactData(_ users: [User]) -> Future<[User], Error> {
        return databaseService.updateUsersWithContactData(users)
    }
}
