//
//  Repository.swift
//  Spika
//
//  Created by Marko on 06.10.2021..
//

import Foundation
import Combine
import UIKit
import CoreData

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
    
    func uploadWholeFile(data: Data) -> (AnyPublisher<(File?, CGFloat), Error>)
    func uploadChunk(chunk: String, offset: Int, clientId: String) -> AnyPublisher<UploadChunkResponseModel, Error>
    func verifyUpload(total: Int, size: Int, mimeType: String, fileName: String, clientId: String, fileHash: String, type: String, relationId: Int) -> AnyPublisher<VerifyFileResponseModel, Error>
    
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
    
    func sendTextMessage(body: MessageBody, roomId: Int) -> AnyPublisher<SendMessageResponse, Error>
    
    // MARK: - COREDATA
    
    func getMainContext() -> NSManagedObjectContext
//    func trySaveChanges() -> Future<Bool, Error>
    
    // MARK: COREDATA: User
    
    func getUsers() -> Future<[User], Error>
    func saveUser(_ user: User) -> Future<User, Error>
    func saveUsers(_ users: [User]) -> Future<[User], Error>
    
    // MARK: COREDATA: Messages
    
    func saveMessage(message: Message) -> Future<(Message, String), Error>
    func getMessages(forRoomId: Int) -> Future<[Message], Error>
    func updateLocalMessage(message: Message, localId: String) -> Future<Message, Error>
    
    // MARK: COREDATA: Room
    
    func checkPrivateLocalRoom(forId id: Int) -> Future<Room, Error>
    func saveRoom(room: Room) -> Future<Room, Error>

    // MARK: - USERDEFAULTS: User
    
    func saveUserInfo(user: User, device: Device?)
    func getMyUserId() -> Int
    func getAccessToken() -> String?
    func getMyDeviceId() -> Int
}
