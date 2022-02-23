//
//  Repository.swift
//  Spika
//
//  Created by Marko on 06.10.2021..
//

import Foundation
import Combine

enum RepositoryType {
    case production, test
    
    var name: String {
        switch self {
        case .production:
            return "production"
        case .test:
            return "test"
        }
    }
}

protocol Repository {
    // this is test endpoint, needs to be deleted in future
    func getPosts() -> AnyPublisher<[Post], Error>
    func createChat(_ chat: Chat) -> Future<Chat, Error>
    func getChats() -> Future<[Chat], Error>
    func updateChat(_ chat: Chat) -> Future<Chat, Error>
    func authenticateUser(telephoneNumber: String, deviceId: String) -> AnyPublisher<AuthResponseModel, Error>
    func verifyCode(code: String, deviceId: String) -> AnyPublisher<AuthResponseModel, Error>
    func saveUserInfo(user: AppUser, device: Device)
    func getUsers() -> Future<[User], Error>
    func saveUser(_ user: User) -> Future<User, Error>
    func addUserToChat(chat: Chat, user: User) -> Future<Chat, Error>
    func getUsersForChat(chat: Chat) -> Future<[User], Error>
    func saveMessage(_ message: Message) -> Future<Message, Error>
    func getMessagesForChat(chat: Chat) -> Future<[Message], Error>
    func uploadWholeFile(data: Data) -> Int
    func uploadChunk(chunk: String, offset: Int, total: Int, size: Int, mimeType: String, fileName: String, clientId: String, type: String, fileHash: String, relationId: Int) -> AnyPublisher<UploadFileResponseModel, Error>
    func updateUsername(username: String) -> AnyPublisher<UserResponseModel, Error>
    func postContacts(hashes: [String]) -> AnyPublisher<ContactsResponseModel, Error>
    func getContacts(page: Int) -> AnyPublisher<ContactsResponseModel, Error>
}
