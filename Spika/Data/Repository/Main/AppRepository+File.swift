//
//  AppRepository+File.swift
//  Spika
//
//  Created by Nikola Barbarić on 02.01.2023..
//

import Foundation
import Combine
import CryptoKit

extension AppRepository {
    @available(iOSApplicationExtension 13.4, *)
    func uploadAllChunks(fromUrl url: URL) -> AnyPublisher<(percentUploaded: CGFloat, chunksDataToVerify: ChunksDataToVerify?), Error> {
        let chunkSize = 1024 * 4
        let clientId = UUID().uuidString
        var hasher = SHA256()
        var hash: String?
        let somePublisher = PassthroughSubject<(percentUploaded: CGFloat, chunksDataToVerify: ChunksDataToVerify?), Error>()
        
        guard FileManager.default.fileExists(atPath: url.path),
              let outputFileHandle = try? FileHandle(forReadingFrom: url),
              let resources = try? url.resourceValues(forKeys:[.fileSizeKey]),
              let fileSize = resources.fileSize
//              let fileName = resources.name
        else {
            return somePublisher.eraseToAnyPublisher()
        }
        
        let totalChunks = fileSize / chunkSize + (fileSize % chunkSize != 0 ? 1 : 0)
        var chunk = try? outputFileHandle.read(upToCount: chunkSize)
        var chunkOffset = 0
        while (chunk != nil) {
            guard let safeChunk = chunk else { break }
            hasher.update(data: safeChunk)
            hash = hasher.finalize().compactMap { String(format: "%02x", $0)}.joined()
            
            uploadChunk(chunk: safeChunk.base64EncodedString(),
                        offset: chunkOffset,
                        clientId: clientId).sink { [weak self] completion in
                guard let _ = self else { return }
                switch completion {
                case let .failure(error):
                    print("Upload chunk error", error)
                    somePublisher.send(completion: .failure(NetworkError.chunkUploadFail))
                case .finished:
                    break
                }
            } receiveValue: { uploadChunkResponseModel in
                guard let uploadedCount = uploadChunkResponseModel.data?.uploadedChunks?.count else { return }
                let percent = CGFloat(uploadedCount) / CGFloat(totalChunks)
                somePublisher.send((percentUploaded: percent, chunksDataToVerify: nil))
                print("CHUNK Percent: ", percent)
                if uploadedCount == totalChunks {
                    guard let hash = hash else { return }
                    somePublisher.send((percentUploaded: 1, chunksDataToVerify: ChunksDataToVerify(totalChunks: totalChunks, size: fileSize, fileName: "ovod", clientId: clientId, fileHash: hash)))
                }
            }.store(in: &subs)
            chunk = try? outputFileHandle.read(upToCount: chunkSize)
            chunkOffset += 1
        }
        
        try? outputFileHandle.close()
        return somePublisher.eraseToAnyPublisher()
    }
    
    func uploadAllChunks(fromData data: Data) -> AnyPublisher<(percentUploaded: CGFloat, chunksDataToVerify: ChunksDataToVerify?), Error> {
            
            let dataLen: Int = data.count
            let chunkSize: Int = ((1024) * 4)
            let fullChunks = Int(dataLen / chunkSize)
            let totalChunks: Int = fullChunks + (dataLen % 1024 != 0 ? 1 : 0)
            let clientId = UUID().uuidString
            var hasher = SHA256()
            var hash: String?
            let somePublisher = PassthroughSubject<(percentUploaded: CGFloat, chunksDataToVerify: ChunksDataToVerify?), Error>()

            for chunkCounter in 0..<totalChunks {
                var chunk:Data
                let chunkBase: Int = chunkCounter * chunkSize
                var diff = chunkSize
                if(chunkCounter == totalChunks - 1) {
                    diff = dataLen - chunkBase
                }
                
                let range:Range<Data.Index> = chunkBase..<(chunkBase + diff)
                chunk = data.subdata(in: range)
                
                hasher.update(data: chunk)
                if chunkCounter == totalChunks - 1 {
                    hash = hasher.finalize().compactMap { String(format: "%02x", $0)}.joined()
                }
                
                uploadChunk(chunk: chunk.base64EncodedString(), offset: chunkBase/chunkSize, clientId: clientId).sink { [weak self] completion in
                    guard let _ = self else { return }
                    switch completion {
                    case let .failure(error):
                        print("Upload chunk error", error)
                        somePublisher.send(completion: .failure(NetworkError.chunkUploadFail))
                    case .finished:
                        break
                    }
                } receiveValue: { [weak self] uploadChunkResponseModel in
                    guard let self = self else { return }
                    guard let uploadedCount = uploadChunkResponseModel.data?.uploadedChunks?.count else { return }
                    let percent = CGFloat(uploadedCount) / CGFloat(totalChunks)
                    somePublisher.send((percentUploaded: percent, chunksDataToVerify: nil))
                    
                    if uploadedCount == totalChunks {
                        guard let hash = hash else { return }
                        somePublisher.send((percentUploaded: 1,
                                            chunksDataToVerify: ChunksDataToVerify(totalChunks: totalChunks,
                                                                                   size: dataLen,
                                                                                   fileName: "fileName",
                                                                                   clientId: clientId,
                                                                                   fileHash: hash)))
                    }
                }.store(in: &subs)
            }
            
        return somePublisher.eraseToAnyPublisher()
    }
}
