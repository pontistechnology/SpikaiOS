struct UploadChunkResponseModel: Codable {
    let status: String?
    let data: ChunkData?
    let error: String?
    let message: String?
}

// MARK: - DataClass
struct ChunkData: Codable {
    let uploadedChunks: [Int]?
}

struct ChunksDataToVerify: Codable {
    let totalChunks: Int
    let size: Int
    let fileName: String
    let clientId: String
    let fileHash: String
    
}
