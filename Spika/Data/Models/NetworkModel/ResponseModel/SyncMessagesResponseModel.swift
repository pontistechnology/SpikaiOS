import Foundation

struct SyncMessagesResponseModel: Codable {
    let status: String?
    let data: SyncMessagesData?
    let error: String?
    let message: String?
}

struct SyncMessagesData: Codable {
    let messages: [Message]
}
