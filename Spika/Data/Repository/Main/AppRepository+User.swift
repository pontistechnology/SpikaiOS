//
//  AppRepository+User.swift
//  Spika
//
//  Created by Marko on 13.10.2021..
//

import UIKit
import Combine
import CryptoKit

extension AppRepository {
    
    // MARK: UserDefaults
    
    func saveUserInfo(user: User, device: Device? = nil) {
        userDefaults.set(user.id, forKey: Constants.Database.userId)
        userDefaults.set(user.telephoneNumber, forKey: Constants.Database.userPhoneNumber)
        userDefaults.set(user.displayName, forKey: Constants.Database.displayName)
        guard let device = device else { return }
        userDefaults.set(device.id, forKey: Constants.Database.deviceId)
        userDefaults.set(device.token, forKey: Constants.Database.accessToken)
    }
    
    func getMyUserId() -> Int64 {
        return Int64(userDefaults.integer(forKey: Constants.Database.userId))
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
        print("Phone number SHA256: ", telephoneNumber.getSHA256())
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
    
    func postContacts(hashes: [String]) -> AnyPublisher<ContactsResponseModel, Error> {
        guard let accessToken = getAccessToken()
        else { return Fail<ContactsResponseModel, Error>(error: NetworkError.noAccessToken)
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
        let contacts = ContactsRequestModel(contacts: hashes)
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
        return databaseService.userEntityService.getLocalUsers()
    }
    
    func getLocalUser(withId id: Int64) -> Future<User, Error> {
        return databaseService.userEntityService.getLocalUser(withId: id)
    }
    
    func saveUser(_ user: User) -> Future<User, Error> {
        return databaseService.userEntityService.saveUser(user)
    }
    
    func saveUsers(_ users: [User]) -> Future<[User], Error> {
        return databaseService.userEntityService.saveUsers(users)
    }
    
    func saveContacts(_ contacts: [FetchedContact]) -> Future<[FetchedContact], Error> {
        return databaseService.userEntityService.saveContacts(contacts)
    }
    
    func getContact(phoneNumber: String) -> Future<FetchedContact, Error> {
        return databaseService.userEntityService.getContact(phoneNumber: phoneNumber)
    }
    
    func updateUsersWithContactData(_ users: [User]) -> Future<[User], Error> {
        return databaseService.userEntityService.updateUsersWithContactData(users)
    }
}
