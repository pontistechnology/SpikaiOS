import Foundation

struct SyncMessagesResponseModel: Codable {
    let status: String?
    let data: SyncMessagesData?
    let error: String?
    let message: String?
}

struct SyncMessagesData: Codable {
    let list: [Message]
    let limit: Int64
    let count: Int64
    let hasNext: Bool
}
