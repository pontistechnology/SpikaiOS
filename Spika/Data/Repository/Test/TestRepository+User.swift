//
//  TestRepository+User.swift
//  AppTests
//
//  Created by Marko on 27.10.2021..
//

import Foundation
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
    
    func saveUserInfo(user: AppUser, device: Device) {
        print(user)
        print(device)
    }
    
    func getUsers() -> Future<[User], Error> {
        let users = [User(loginName: "Ivan", localName: "Ivan"),
                     User(loginName: "Luka", localName: "Luka")]
        return Future { promise in promise(.success(users))}
    }
    
    func saveUser(_ user: User) -> Future<User, Error> {
        Future { promise in promise(.failure(DatabseError.noSuchRecord))}
    }
    
    func saveUsers(_ user: [User]) -> Future<[User], Error> {
        Future { promise in promise(.failure(DatabseError.noSuchRecord))}
    }
    
    func addUserToChat(chat: Chat, user: User) -> Future<Chat, Error> {
        Future { promise in promise(.failure(DatabseError.noSuchRecord))}
    }
    
    func getUsersForChat(chat: Chat) -> Future<[User], Error> {
        Future { promise in promise(.failure(DatabseError.noSuchRecord))}
    }
    
    func uploadWholeFile(data: Data) -> PassthroughSubject<UploadChunkResponseModel, Error> {
        return PassthroughSubject<UploadChunkResponseModel, Error>()
    }
    
    func uploadChunk(chunk: String, offset: Int, total: Int, size: Int, mimeType: String, fileName: String, clientId: String, type: String, fileHash: String, relationId: Int) -> AnyPublisher<UploadChunkResponseModel, Error> {
        // TODO: - add tests
        return Fail<UploadChunkResponseModel, Error>(error: NetworkError.badURL)
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
    
}
