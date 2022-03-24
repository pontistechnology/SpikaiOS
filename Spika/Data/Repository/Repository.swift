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
    
    var subs: Set<AnyCancellable>{ get set}
    
    // MARK: Network
    // MARK: - Auth
    func authenticateUser(telephoneNumber: String, deviceId: String) -> AnyPublisher<AuthResponseModel, Error>
    func verifyCode(code: String, deviceId: String) -> AnyPublisher<AuthResponseModel, Error>
    
    // MARK: - File upload
    func uploadWholeFile(data: Data) -> (publisher: PassthroughSubject<UploadChunkResponseModel, Error>, totalChunksNumber: Int)
    func uploadChunk(chunk: String, offset: Int, total: Int, size: Int, mimeType: String, fileName: String, clientId: String, type: String, fileHash: String?, relationId: Int) -> AnyPublisher<UploadChunkResponseModel, Error>
    
    // MARK: - User
    func updateUser(username: String?, avatarURL: String?, telephoneNumber: String?, email: String?) -> AnyPublisher<UserResponseModel, Error>
    
    // MARK: - Contacts
    func postContacts(hashes: [String]) -> AnyPublisher<ContactsResponseModel, Error>
    func getContacts(page: Int) -> AnyPublisher<ContactsResponseModel, Error>
    
    // MARK: - Room
    func createRoom(name: String, users: [User]) -> AnyPublisher<CreateRoomResponseModel, Error>
    func checkRoom(forUserId userId: Int) -> AnyPublisher<CheckRoomResponseModel, Error>
    func createRoom(userId: Int) -> AnyPublisher<CreateRoomResponseModel, Error>
    func getAllRooms() -> AnyPublisher<GetAllRoomsResponseModel, Error>
    
    // MARK: - Message
    func sendTextMessage(message: MessageBody, roomId: Int) -> AnyPublisher<SendMessageResponse, Error>
    
    
    // MARK: Database
    func saveUserInfo(user: User, device: Device)
    func getMyUserId() -> Int
    func getUsers() -> Future<[LocalUser], Error>
    func saveUser(_ user: LocalUser) -> Future<LocalUser, Error>
    func saveUsers(_ users: [LocalUser]) -> Future<[LocalUser], Error>
    func saveMessage(_ message: LocalMessage) -> Future<LocalMessage, Error>
    func testnaRepo(naziv: String) -> Future<String, Error>
}
