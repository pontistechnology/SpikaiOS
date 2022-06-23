import Foundation

struct SyncUsersResponseModel: Codable {
    let status: String?
    let data: SyncUsersData?
    let error: String?
    let message: String?
}

struct SyncUsersData: Codable {
    let users: [User]
}
