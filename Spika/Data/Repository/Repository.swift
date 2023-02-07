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
    
    var unreadRoomsPublisher: CurrentValueSubject<Int,Never> { get }
    
    
    // MARK: - NETWORKING: Auth
    
    func authenticateUser(telephoneNumber: String, deviceId: String) -> AnyPublisher<AuthResponseModel, Error>
    func verifyCode(code: String, deviceId: String) -> AnyPublisher<AuthResponseModel, Error>
    
    // MARK: NETWORKING: File upload
    
    @available(iOSApplicationExtension 13.4, *) func uploadWholeFile(fromUrl url: URL, mimeType: String, metaData: MetaData) -> (AnyPublisher<(File?, CGFloat), Error>)
    func uploadChunk(chunk: String, offset: Int, clientId: String) -> AnyPublisher<UploadChunkResponseModel, Error>
    func verifyUpload(total: Int, size: Int, mimeType: String, fileName: String, clientId: String, fileHash: String, type: String, relationId: Int, metaData: MetaData) -> AnyPublisher<VerifyFileResponseModel, Error>
    
    // MARK: NETWORKING: User
    
    func fetchMyUserDetails() -> AnyPublisher<AuthResponseModel, Error>
    func updateUser(username: String?, avatarFileId: Int64?, telephoneNumber: String?, email: String?) -> AnyPublisher<UserResponseModel, Error>
    
    // MARK: NETWORKING: Contacts
    
    func postContacts(hashes: [String]) -> AnyPublisher<ContactsResponseModel, Error>
    func getContacts(page: Int) -> AnyPublisher<ContactsResponseModel, Error>
    
    // MARK: NETWORKING: Room
    
    func createOnlineRoom(name: String, avatarId: Int64?, users: [User]) -> AnyPublisher<CreateRoomResponseModel, Error>
    func createOnlineRoom(userId: Int64) -> AnyPublisher<CreateRoomResponseModel, Error>
    func checkOnlineRoom(forUserId userId: Int64) -> AnyPublisher<CheckRoomResponseModel, Error>
    func checkOnlineRoom(forRoomId roomId: Int64) -> AnyPublisher<CheckRoomResponseModel, Error>
    func deleteOnlineRoom(forRoomId roomId: Int64) -> AnyPublisher<EmptyResponse, Error>
    func getAllRooms() -> AnyPublisher<GetAllRoomsResponseModel, Error>
    
    // MARK: NETWORKING: Message
    
    func sendMessage(body: RequestMessageBody, type: MessageType, roomId: Int64, localId: String, replyId: Int64?) -> AnyPublisher<SendMessageResponse, Error>
    func sendDeliveredStatus(messageIds: [Int64]) -> AnyPublisher<DeliveredResponseModel, Error>
    func sendSeenStatus(roomId: Int64) -> AnyPublisher<SeenResponseModel, Error>
    func sendReaction(messageId: Int64, reaction: String) -> AnyPublisher<SendReactionResponseModel, Error>
    func deleteMessage(messageId: Int64, target: DeleteMessageTarget) -> AnyPublisher<SendMessageResponse, Error>
    
    // MARK: NETWORKING: Sync
    
    func syncRooms(timestamp: Int64) -> AnyPublisher<SyncRoomsResponseModel, Error>
    func syncMessages(timestamp: Int64) -> AnyPublisher<SyncMessagesResponseModel, Error>
    func syncMessageRecords(timestamp: Int64) -> AnyPublisher<SyncMessageRecordsResponseModel, Error>
    func syncUsers(timestamp: Int64) -> AnyPublisher<SyncUsersResponseModel, Error>
    func blockUser(userId: Int64) -> AnyPublisher<EmptyResponse, Error>
    func unblockUser(userId: Int64) -> AnyPublisher<EmptyResponse, Error>
    func getBlockedUsers() -> AnyPublisher<BlockedUsersResponseModel, Error>
    
    func serialWriteQueue() -> DispatchQueue
    func updateBlockedUsers(users: [User])
    func updateConfirmedUsers(confirmedUsers: [User])
    func confirmedUsersPublisher() -> CurrentValueSubject<Set<Int64>,Never>
    func blockedUsersPublisher() -> CurrentValueSubject<Set<Int64>?,Never>
    
    // MARK: NETWORKING: Device
    
    func updatePushToken() -> AnyPublisher<UpdatePushResponseModel, Error>
    
    // MARK: - COREDATA
    
    func getMainContext() -> NSManagedObjectContext
//    func trySaveChanges() -> Future<Bool, Error>
    
    // MARK: COREDATA: User
    
    func getLocalUsers() -> Future<[User], Error>
    func getLocalUser(withId id: Int64) -> Future<User, Error>
    func saveUser(_ user: User) -> Future<User, Error>
    func saveUsers(_ users: [User]) -> Future<[User], Error>
    
    // MARK: COREDATA: Messages
    
    func saveMessages(_ messages: [Message]) -> Future<[Message], Error>
    func saveMessageRecords(_ messageRecords: [MessageRecord]) -> Future<[MessageRecord], Error>
    func getMessages(forRoomId: Int64) -> Future<[Message], Error>
    func printAllMessages()
    func getNotificationInfoForMessage(_ message: Message) -> Future<MessageNotificationInfo, Error>
    
    // MARK: COREDATA: Room
    
    func checkLocalRoom(forUserId id: Int64) -> Future<Room, Error>
    func getRoomWithId(forRoomId id: Int64) -> Future<Room, Error>
    func saveLocalRooms(rooms: [Room]) -> Future<[Room], Error>
    func updateRoomUsers(room: Room) -> Future<Room, Error>
    func checkLocalRoom(withId roomId: Int64) -> Future<Room, Error>
    func roomVisited(roomId: Int64)
    func muteUnmuteRoom(roomId: Int64, mute: Bool) -> AnyPublisher<EmptyResponse,Error>
    func updateRoomUsers(roomId: Int64, userIds: [Int64]) -> AnyPublisher<CreateRoomResponseModel,Error>
    func updateRoomAdmins(roomId: Int64, adminIds: [Int64]) -> AnyPublisher<CreateRoomResponseModel,Error>
    func updateRoomAvatar(roomId: Int64, avatarId: Int64) -> AnyPublisher<CreateRoomResponseModel,Error>
    func deleteLocalRoom(roomId: Int64) -> Future<Bool, Error>

    // MARK: - USERDEFAULTS: User
    
    func saveUserInfo(user: User, device: Device?)
    func getMyUserId() -> Int64
    func getAccessToken() -> String?
    func getMyDeviceId() -> Int64
    func getSyncTimestamp(for type: SyncType) -> Int64
    func setSyncTimestamp(for type: SyncType, timestamp: Int64)
    func getCurrentAppereance() -> Int
    
    // MARK: COREDATA: Contacts
    func saveContacts(_ contacts: [FetchedContact]) -> Future<[FetchedContact], Error>
    func getContact(phoneNumber: String) -> Future<FetchedContact, Error>
    @discardableResult func updateUsersWithContactData(_ users: [User]) -> Future<[User], Error>
    
    // MARK: - FILES
    func saveDataToFile(_ data: Data, name: String) -> URL?
    func copyFile(from fromURL: URL, name: String) -> URL?
    func getFile(name: String) -> URL?
}
