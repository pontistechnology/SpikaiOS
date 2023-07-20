import Foundation

struct SyncUsersResponseModel: Codable {
    let status: String?
    let data: SyncUsersData?
    let error: String?
    let message: String?
}

struct SyncUsersData: Codable {
    let list: [User]
    let limit: Int64
    let count: Int64
    let hasNext: Bool
}
