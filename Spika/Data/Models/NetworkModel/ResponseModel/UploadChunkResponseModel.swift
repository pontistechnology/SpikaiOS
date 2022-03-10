struct UploadChunkResponseModel: Codable {
    let status: String?
    let data: FileData?
    let error: String?
    let message: String?
}

// MARK: - DataClass
struct FileData: Codable {
    let file: File?
    let uploadedChunks: [Int]?
}

// MARK: - File
struct File: Codable {
    let id: Int?
    let type: String?
    let relationId: Int?
    let path: String?
    let mimeType: String?
    let fileName: String?
    let size: Int?
    let clientId: String?
    let createdAt: Int?
    let modifiedAt: Int?
}
