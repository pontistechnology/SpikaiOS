import Foundation

struct SyncMessageRecordsResponseModel: Codable {
    let status: String?
    let data: SyncMessageRecordsData?
    let error: String?
    let message: String?
}

struct SyncMessageRecordsData: Codable {
    let list: [MessageRecord]
    let limit: Int64
    let count: Int64
    let hasNext: Bool
}
