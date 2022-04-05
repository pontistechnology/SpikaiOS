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
    
    // MARK: - Properties
    
    var subs: Set<AnyCancellable>{ get set}
    
    
    // MARK: - NETWORKING: Auth
    
    func authenticateUser(telephoneNumber: String, deviceId: String) -> AnyPublisher<AuthResponseModel, Error>
    func verifyCode(code: String, deviceId: String) -> AnyPublisher<AuthResponseModel, Error>
    
    // MARK: NETWORKING: File upload
    
    func uploadWholeFile(data: Data) -> (publisher: PassthroughSubject<UploadChunkResponseModel, Error>, totalChunksNumber: Int)
    func uploadChunk(chunk: String, offset: Int, total: Int, size: Int, mimeType: String, fileName: String, clientId: String, type: String, fileHash: String?, relationId: Int) -> AnyPublisher<UploadChunkResponseModel, Error>
    
    // MARK: NETWORKING: User
    
    func updateUser(username: String?, avatarURL: String?, telephoneNumber: String?, email: String?) -> AnyPublisher<UserResponseModel, Error>
    
    // MARK: NETWORKING: Contacts
    
    func postContacts(hashes: [String]) -> AnyPublisher<ContactsResponseModel, Error>
    func getContacts(page: Int) -> AnyPublisher<ContactsResponseModel, Error>
    
    // MARK: NETWORKING: Room
    
    func createRoom(name: String, users: [User]) -> AnyPublisher<CreateRoomResponseModel, Error>
    func createRoom(userId: Int) -> AnyPublisher<CreateRoomResponseModel, Error>
    func checkRoom(forUserId userId: Int) -> AnyPublisher<CheckRoomResponseModel, Error>
    func getAllRooms() -> AnyPublisher<GetAllRoomsResponseModel, Error>
    
    // MARK: NETWORKING: Message
    
    func sendTextMessage(message: MessageBody, roomId: Int) -> AnyPublisher<SendMessageResponse, Error>
    
    // MARK: - COREDATA: User
    
    func getUsers() -> Future<[LocalUser], Error>
    func saveUser(_ user: LocalUser) -> Future<LocalUser, Error>
    func saveUsers(_ users: [LocalUser]) -> Future<[LocalUser], Error>
    
    // MARK: COREDATA: Messages
    
    func saveMessage(_ message: LocalMessage) -> Future<LocalMessage, Error>
    func testnaRepo(naziv: String) -> Future<String, Error>
    
    // MARK: COREDATA: Room
    
    func checkPrivateLocalRoom(forId id: Int)  -> Future<Room, Error>

    // MARK: - USERDEFAULTS: User
    
    func saveUserInfo(user: User, device: Device?)
    func getMyUserId() -> Int
    func getAccessToken() -> String?
    func getMyDeviceId() -> Int
}
