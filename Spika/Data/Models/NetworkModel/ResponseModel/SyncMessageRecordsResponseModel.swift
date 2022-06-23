import Foundation

struct SyncMessageRecordsResponseModel: Codable {
    let status: String?
    let data: SyncMessageRecordsData?
    let error: String?
    let message: String?
}

struct SyncMessageRecordsData: Codable {
    let messageRecords: [MessageRecord]
}
