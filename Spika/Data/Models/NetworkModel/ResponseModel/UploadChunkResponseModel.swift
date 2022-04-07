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
