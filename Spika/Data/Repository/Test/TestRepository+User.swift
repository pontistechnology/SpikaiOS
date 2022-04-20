//
//  TestRepository+User.swift
//  AppTests
//
//  Created by Marko on 27.10.2021..
//

import Foundation
import UIKit
import Combine

extension TestRepository {
    
    func authenticateUser(telephoneNumber: String, deviceId: String) -> AnyPublisher<AuthResponseModel, Error> {
        return Fail<AuthResponseModel, Error>(error: NetworkError.badURL)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func verifyCode(code: String, deviceId: String) -> AnyPublisher<AuthResponseModel, Error> {
        return Fail<AuthResponseModel, Error>(error: NetworkError.badURL)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func saveUserInfo(user: User, device: Device?) {
        print(user)
    }
    
    func getMyUserId() -> Int {
        999
    }
    
    func getAccessToken() -> String? {
        "pferde"
    }
    
    func getMyDeviceId() -> Int {
        -1
    }
    
    func getUsers() -> Future<[User], Error> {
        let users = [User(id: 1337, displayName: "Mirko"),
                     User(id: 1337, displayName: "Slavko")]
        return Future { promise in promise(.success(users))}
    }
    
    func saveUser(_ user: User) -> Future<User, Error> {
        Future { promise in promise(.failure(DatabseError.noSuchRecord))}
    }
    
    func saveUsers(_ user: [User]) -> Future<[User], Error> {
        Future { promise in promise(.failure(DatabseError.noSuchRecord))}
    }
    
    func uploadChunk(chunk: String, offset: Int, total: Int, size: Int, mimeType: String, fileName: String, clientId: String, type: String, fileHash: String?, relationId: Int) -> AnyPublisher<UploadChunkResponseModel, Error> {
        // TODO: - add tests
        return Fail<UploadChunkResponseModel, Error>(error: NetworkError.badURL)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func uploadWholeFile(data: Data) -> (AnyPublisher<(File?, CGFloat), Error>) {
        return Fail<(File?, CGFloat), Error>(error: DatabseError.unknown)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func uploadChunk(chunk: String, offset: Int, clientId: String) -> AnyPublisher<UploadChunkResponseModel, Error> {
        return Fail<UploadChunkResponseModel, Error>(error: DatabseError.unknown)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func verifyUpload(total: Int, size: Int, mimeType: String, fileName: String, clientId: String, fileHash: String, type: String, relationId: Int) -> AnyPublisher<VerifyFileResponseModel, Error> {
        return Fail<VerifyFileResponseModel, Error>(error: DatabseError.unknown)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func updateUser(username: String?, avatarURL: String?, telephoneNumber: String?, email: String?) -> AnyPublisher<UserResponseModel, Error> {
        // TODO: - add tests
        return Fail<UserResponseModel, Error>(error: NetworkError.badURL)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func postContacts(hashes: [String]) -> AnyPublisher<ContactsResponseModel, Error> {
        return Fail<ContactsResponseModel, Error>(error: NetworkError.badURL)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func getContacts(page: Int) -> AnyPublisher<ContactsResponseModel, Error> {
        return Fail<ContactsResponseModel, Error>(error: NetworkError.badURL)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func saveContacts(_ contacts: [FetchedContact]) -> Future<[FetchedContact], Error> {
        Future { promise in promise(.failure(DatabseError.noSuchRecord))}
    }
    
    func getContact(phoneNumber: String) -> Future<FetchedContact, Error> {
        Future { promise in promise(.failure(DatabseError.noSuchRecord))}
    }
}
