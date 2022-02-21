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
    
    func updateUsername(username: String) -> AnyPublisher<UserResponseModel, Error>{
        
        guard let accessToken = UserDefaults.standard.string(forKey: Constants.UserDefaults.accessToken)
        else {return Fail<UserResponseModel, Error>(error: NetworkError.noAccessToken)
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
        let resources = Resources<UserResponseModel, UserRequestModel>(
            path: Constants.Endpoints.userInfo,
            requestType: .PUT,
            bodyParameters: UserRequestModel(displayName: username),
            httpHeaderFields: ["accesstoken" : accessToken])
        return networkService.performRequest(resources: resources)
    }
    
    func saveUserInfo(user: AppUser, device: Device) {
        let defaults = UserDefaults.standard
        defaults.set(user.id, forKey: Constants.UserDefaults.userId)
        defaults.set(user.telephoneNumber, forKey: Constants.UserDefaults.userPhoneNumber)
        defaults.set(device.id, forKey: Constants.UserDefaults.deviceId)
        defaults.set(device.token, forKey: Constants.UserDefaults.accessToken)
    }
    
    func getUsers() -> Future<[User], Error> {
        return databaseService.userEntityService.getUsers()
    }
    
    func saveUser(_ user: User) -> Future<User, Error> {
        return databaseService.userEntityService.saveUser(user)
    }
    
    func uploadFile(chunk: String, offset: Int, total: Int, size: Int, mimeType: String, fileName: String, clientId: String, type: String,
                    fileHash: String,
                    relationId: Int) -> AnyPublisher<UploadFileResponseModel, Error> {
        guard let accessToken = UserDefaults.standard.string(forKey: Constants.UserDefaults.accessToken)
        else {return Fail<UploadFileResponseModel, Error>(error: NetworkError.noAccessToken)
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
        let resources = Resources<UploadFileResponseModel, UploadFileRequestModel>(
            path: Constants.Endpoints.uploadFiles,
            requestType: .POST,
            bodyParameters: UploadFileRequestModel(chunk: chunk, offset: offset, total: total, size: size, mimeType: mimeType, fileName: fileName, clientId: clientId, type: type, fileHash: fileHash, relationId: relationId),
            httpHeaderFields: ["accesstoken" : accessToken]) //access token
        
        return networkService.performRequest(resources: resources)
    }
    
    func postContacts(hashes: [String]) -> AnyPublisher<[String: String], Error> {
        let resources = Resources<[String: String], [String]>(
            path: Constants.Endpoints.contacts,
            requestType: .POST,
            bodyParameters: hashes,
            httpHeaderFields: ["accesstoken" : "5BfRl2zv0GZehWA7"])
        return networkService.performRequest(resources: resources)
    }
}
