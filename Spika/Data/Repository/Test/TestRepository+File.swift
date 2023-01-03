//
//  TestRepository+File.swift
//  Spika
//
//  Created by Nikola Barbarić on 02.01.2023..
//

import Combine
import Foundation

extension TestRepository {
    func uploadAllChunks(fromUrl url: URL) -> AnyPublisher<(percentUploaded: CGFloat, chunksDataToVerify: ChunksDataToVerify?), Error> {
        return Fail<(percentUploaded: CGFloat, chunksDataToVerify: ChunksDataToVerify?), Error>(error: DatabseError.unknown)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func uploadAllChunks(fromData data: Data) -> AnyPublisher<(percentUploaded: CGFloat, chunksDataToVerify: ChunksDataToVerify?), Error> {
        return Fail<(percentUploaded: CGFloat, chunksDataToVerify: ChunksDataToVerify?), Error>(error: DatabseError.unknown)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
