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
    
    func createOnlineRoom(name: String, users: [User]) -> AnyPublisher<CreateRoomResponseModel, Error>
    func createOnlineRoom(userId: Int) -> AnyPublisher<CreateRoomResponseModel, Error>
    func checkOnlineRoom(forUserId userId: Int) -> AnyPublisher<CheckRoomResponseModel, Error>
    func checkOnlineRoom(forRoomId roomId: Int) -> AnyPublisher<CheckRoomResponseModel, Error>
    func getAllRooms() -> AnyPublisher<GetAllRoomsResponseModel, Error>
    
    // MARK: NETWORKING: Message
    
    func sendTextMessage(body: MessageBody, roomId: Int, localId: String) -> AnyPublisher<SendMessageResponse, Error>
    func sendDeliveredStatus(messageIds: [Int]) -> AnyPublisher<DeliveredResponseModel, Error>
    
    // MARK: NETWORKING: MessageRecords
    
    func getMessageRecordsAfter(timestamp: Int) -> AnyPublisher<MessageRecordSyncResponseModel, Error>
    
    // MARK: NETWORKING: Device
    
    func updatePushToken() -> AnyPublisher<UpdatePushResponseModel, Error>
    
    // MARK: - COREDATA
    
    func getMainContext() -> NSManagedObjectContext
//    func trySaveChanges() -> Future<Bool, Error>
    
    // MARK: COREDATA: User
    
    func getLocalUsers() -> Future<[User], Error>
    func getLocalUser(withId id: Int) -> Future<User, Error>
    func saveUser(_ user: User) -> Future<User, Error>
    func saveUsers(_ users: [User]) -> Future<[User], Error>
    
    // MARK: COREDATA: Messages
    
    func saveMessage(message: Message, roomId: Int) -> Future<Message, Error>
    func saveMessageRecord(messageRecord: MessageRecord) -> Future<MessageRecord, Error>
    func getMessages(forRoomId: Int) -> Future<[Message], Error>
//    func updateLocalMessage(message: Message, localId: String) -> Future<Message, Error>
    
    // MARK: COREDATA: Room
    
    func checkPrivateLocalRoom(forUserId id: Int) -> Future<Room, Error>
    func saveLocalRoom(room: Room) -> Future<Room, Error>
    func checkLocalRoom(withId roomId: Int) -> Future<Room, Error>

    // MARK: - USERDEFAULTS: User
    
    func saveUserInfo(user: User, device: Device?)
    func getMyUserId() -> Int
    func getAccessToken() -> String?
    func getMyDeviceId() -> Int
}
