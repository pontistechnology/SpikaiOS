struct UploadFileResponseModel: Codable {
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
    let id: Int
    let fileName: String
    let size: Int
    let mimeType: String
    let type: String
    let relationId: Int
}
