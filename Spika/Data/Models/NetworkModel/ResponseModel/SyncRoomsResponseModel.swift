import Foundation

struct SyncRoomsResponseModel: Codable {
    let status: String?
    let data: SyncRoomsData?
    let error: String?
    let message: String?
}

struct SyncRoomsData: Codable {
    let list: [Room]
    let limit: Int64
    let count: Int64
    let hasNext: Bool
}
