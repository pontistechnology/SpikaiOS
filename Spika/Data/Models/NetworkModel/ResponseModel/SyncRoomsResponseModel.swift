import Foundation

struct SyncRoomsResponseModel: Codable {
    let status: String?
    let data: SyncRoomsData?
    let error: String?
    let message: String?
}

struct SyncRoomsData: Codable {
    let rooms: [Room]
}
