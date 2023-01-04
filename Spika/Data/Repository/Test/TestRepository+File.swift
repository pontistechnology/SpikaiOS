//
//  TestRepository+File.swift
//  Spika
//
//  Created by Nikola Barbarić on 02.01.2023..
//

import Combine
import Foundation

extension TestRepository {
    func uploadAllChunks(fromUrl url: URL, mimeType: String, metaData: MetaData) -> AnyPublisher<(percentUploaded: CGFloat, chunksDataToVerify: ChunksDataToVerify?), Error> {
        return Fail<(percentUploaded: CGFloat, chunksDataToVerify: ChunksDataToVerify?), Error>(error: DatabseError.unknown)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func uploadAllChunks(fromData data: Data, mimeType: String, metaData: MetaData) -> AnyPublisher<(percentUploaded: CGFloat, chunksDataToVerify: ChunksDataToVerify?), Error> {
        return Fail<(percentUploaded: CGFloat, chunksDataToVerify: ChunksDataToVerify?), Error>(error: DatabseError.unknown)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

extension TestRepository {
    func uploadWholeFile(data: Data, mimeType: String, metaData: MetaData) -> (AnyPublisher<(File?, CGFloat), Error>) {
        return Fail<(File?, CGFloat), Error>(error: DatabseError.unknown)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func uploadChunk(chunk: String, offset: Int, clientId: String) -> AnyPublisher<UploadChunkResponseModel, Error> {
        return Fail<UploadChunkResponseModel, Error>(error: DatabseError.unknown)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func verifyUpload(total: Int, size: Int, mimeType: String, fileName: String, clientId: String, fileHash: String, type: String, relationId: Int, metaData: MetaData) -> AnyPublisher<VerifyFileResponseModel, Error> {
        return Fail<VerifyFileResponseModel, Error>(error: DatabseError.unknown)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func uploadWholeFile(fromUrl url: URL, mimeType: String, metaData: MetaData) -> (AnyPublisher<(File?, CGFloat), Error>) {
        return Fail<(File?, CGFloat), Error>(error: DatabseError.unknown)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
