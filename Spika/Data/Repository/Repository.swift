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
    // Properties
    var subs: Set<AnyCancellable>{ get set}


// MARK: - NETWORKING:
    
        // Auth
    func openTermsAndConditions()
    func getAppModeIsTeamChat() -> Future<Bool?, Error>
    func getServerSettings() -> AnyPublisher<ServerSettingsResponseModel, Error>
    func authenticateUser(telephoneNumber: String, deviceId: String) -> AnyPublisher<AuthResponseModel, Error>
    func verifyCode(code: String, deviceId: String) -> AnyPublisher<AuthResponseModel, Error>
    
        // File upload
    func uploadWholeFile(fromUrl url: URL, mimeType: String, metaData: MetaData, specificFileName: String?) -> (AnyPublisher<(File?, CGFloat), Error>)
    func uploadChunk(chunk: String, offset: Int, clientId: String) -> AnyPublisher<UploadChunkResponseModel, Error>
    func verifyUpload(total: Int, size: Int, mimeType: String, fileName: String, clientId: String, fileHash: String, type: String, relationId: Int, metaData: MetaData) -> AnyPublisher<VerifyFileResponseModel, Error>
    
        // User
    func fetchMyUserDetails() -> AnyPublisher<AuthResponseModel, Error>
    func updateUser(username: String?, avatarFileId: Int64?, telephoneNumber: String?, email: String?) -> AnyPublisher<UserResponseModel, Error>
    func deleteMyAccount() -> AnyPublisher<DeleteAccountResponseModel, Error>
    
        // Contacts
    func postContacts(hashes: [String], lastPage: Bool) -> AnyPublisher<ContactsResponseModel, Error>
    func getContacts(page: Int) -> AnyPublisher<ContactsResponseModel, Error>
    
        // Room
    func createOnlineRoom(name: String, avatarId: Int64?, userIds: [Int64]) -> AnyPublisher<CreateRoomResponseModel, Error>
    func createOnlineRoom(userId: Int64) -> AnyPublisher<CreateRoomResponseModel, Error>
    func checkOnlineRoom(forUserId userId: Int64) -> AnyPublisher<CheckRoomResponseModel, Error>
    func checkOnlineRoom(forRoomId roomId: Int64) -> AnyPublisher<CheckRoomResponseModel, Error>
    func deleteOnlineRoom(forRoomId roomId: Int64) -> AnyPublisher<EmptyResponse, Error>
    func leaveOnlineRoom(forRoomId roomId: Int64) -> AnyPublisher<CreateRoomResponseModel, Error>
    func getAllRooms() -> AnyPublisher<GetAllRoomsResponseModel, Error>
    func updateRoom(roomId: Int64, action: UpdateRoomAction) -> AnyPublisher<CreateRoomResponseModel, Error>
    
        // Message
    func sendMessage(body: RequestMessageBody, type: MessageType, roomId: Int64, localId: String, replyId: Int64?) -> AnyPublisher<MessageResponse, Error>
    func sendDeliveredStatus(messageIds: [Int64]) -> Future<Bool, Never>
    func sendSeenStatus(roomId: Int64)
    func sendReaction(messageId: Int64, reaction: String) -> AnyPublisher<RecordResponseModel, Error>
    func deleteMessageRecord(recordId: Int64) -> AnyPublisher<RecordResponseModel, Error>
    func deleteMessage(messageId: Int64, target: DeleteMessageTarget) -> AnyPublisher<MessageResponse, Error>
    func updateMessage(messageId: Int64, text: String) -> AnyPublisher<MessageResponse, Error>
    func forwardMessages(messageIds: [Int64], roomIds: [Int64], userIds: [Int64]) -> AnyPublisher<ForwardMessagesResponseModel, Error>
    
        // Notes
    
    func getAllNotes(roomId: Int64) -> AnyPublisher<AllNotesResponseModel, Error>
    func updateNote(title: String, content: String, id: Int64) -> AnyPublisher<OneNoteResponseModel, Error>
    func createNote(title: String, content: String, roomId: Int64) -> AnyPublisher<OneNoteResponseModel, Error>
    func deleteNote(id: Int64) -> AnyPublisher<EmptyResponse, Error>
    
        // Sync
    func syncRooms(page: Int, startingTimestamp: Int64)
    func syncUsers(page: Int, startingTimestamp: Int64)
    func syncMessageRecords(page: Int, startingTimestamp: Int64)
    func syncMessages(page: Int, startingTimestamp: Int64)
    func syncContacts(force: Bool?)
    func getSyncTimestamp(for type: SyncType) -> Int64

        // Block
    func blockUser(userId: Int64) -> AnyPublisher<EmptyResponse, Error>
    func getBlockedUsers() -> AnyPublisher<BlockedUsersResponseModel, Error>
    func unblockUser(userId: Int64) -> AnyPublisher<EmptyResponse, Error>
    func syncBlockedList()
    
        // Unread counts
    func refreshUnreadCounts()
    
        // Device
    func updatePushToken() -> AnyPublisher<UpdatePushResponseModel, Error>
    
    
    // MARK: - COREDATA
    
    func getMainContext() -> NSManagedObjectContext
    func deleteLocalDatabase()
    
        // Contacts
    func getPhoneContacts() -> Future<ContactFetchResult, Error>
    func saveContacts(_ contacts: [FetchedContact]) -> Future<[FetchedContact], Error>
    @discardableResult func updateUsersWithContactData(_ users: [User]) -> Future<[User], Error>
    
        // User
    func getLocalUsers() -> Future<[User], Error>
    func getLocalUser(withId id: Int64) -> Future<User, Error>
    func saveUsers(_ users: [User]) -> Future<[User], Error>
    
        // RoomUser
    func getRoomUsers(roomId: Int64, context: NSManagedObjectContext) -> [RoomUser]?
    
        // Messages
    func saveMessages(_ messages: [Message]) -> Future<Bool, Error>
    func saveMessageRecords(_ messageRecords: [MessageRecord]) -> Future<Bool, Error>
    func getLastMessage(roomId: Int64, context: NSManagedObjectContext) -> Message?
    func getNotificationInfoForMessage(_ message: Message) -> Future<MessageNotificationInfo, Error>
    func updateMessageSeenDeliveredCount(messageId: Int64, seenCount: Int64, deliveredCount: Int64)
    
        // Message Records
    func getReactionRecords(messageId: String?, context: NSManagedObjectContext) -> [MessageRecord]?
    
        // Room
    func checkLocalPrivateRoom(forUserId id: Int64) -> Future<Room, Error>
    func getRoomWithId(forRoomId id: Int64) -> Future<Room, Error>
    func saveLocalRooms(rooms: [Room]) -> Future<[Room], Error>
    func updateRoomUsers(room: Room) -> Future<Room, Error>
    func checkLocalRoom(withId roomId: Int64) -> Future<Room, Error>
    func muteUnmuteRoom(roomId: Int64, mute: Bool) -> AnyPublisher<EmptyResponse,Error>
    func pinUnpinRoom(roomId: Int64, pin: Bool) -> AnyPublisher<EmptyResponse,Error> 
//    func updateRoomUsers(roomId: Int64, userIds: [Int64]) -> AnyPublisher<CreateRoomResponseModel,Error>
//    func updateRoomAdmins(roomId: Int64, adminIds: [Int64]) -> AnyPublisher<CreateRoomResponseModel,Error>
//    func updateRoomAvatar(roomId: Int64, avatarId: Int64) -> AnyPublisher<CreateRoomResponseModel,Error>
//    func updateRoomName(roomId: Int64, newName: String) -> AnyPublisher<CreateRoomResponseModel,Error>
    func deleteLocalRoom(roomId: Int64) -> Future<Bool, Error>
    func updateUnreadCounts(unreadCounts: [UnreadCount])
    func updateUnreadCountToZeroFor(roomId: Int64)
    func generateRoomModelsWithUsers(context: NSManagedObjectContext, roomEntities: [RoomEntity]) -> Future<[Room], Error>
    
        // File
    func getFileData(id: String?, context: NSManagedObjectContext) -> FileData?
    func getFileData(localId: String?, context: NSManagedObjectContext) -> FileData?

    // MARK: - USERDEFAULTS:
    
    func deleteUserDefaults()
    
        // User
    func saveUserInfo(user: User, device: Device?, telephoneNumber: TelephoneNumber?)
    func getMyUserId() -> Int64
    func getMyTelephoneNumber() -> TelephoneNumber?

        // Device
    func getAccessToken() -> String?
    func getMyDeviceId() -> String?
    
        // Reactions
    func getEmojis() -> [[Emoji]]
    func addToRecentEmojis(emoji: Emoji)
    
        // Theme
    func saveSelectedTheme(_ theme: String)
    func getSelectedTheme() -> String
    
    // MARK: - FILES
    func saveDataToFile(_ data: Data, name: String) -> URL?
    func copyFile(from fromURL: URL, name: String) -> URL?
    func getFile(name: String) -> URL?
    func deleteAllFiles()
    
    // TODO: - move, refactor
    func serialWriteQueue() -> DispatchQueue
    func updateBlockedUsers(users: [User])
    func blockedUsersPublisher() -> CurrentValueSubject<Set<Int64>?,Never>
    
    // MARK: - Notifications
    
    func removeNotificationsWith(roomId: Int64)
    
}
