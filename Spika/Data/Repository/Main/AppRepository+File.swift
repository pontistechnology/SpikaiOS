//
//  AppRepository+File.swift
//  Spika
//
//  Created by Nikola Barbarić on 02.01.2023..
//

import Foundation
import Combine
import CryptoKit
import CoreData

extension AppRepository {
    
    func uploadChunk(chunk: String, offset: Int, clientId: String) -> AnyPublisher<UploadChunkResponseModel, Error> {
        
        guard let accessToken = getAccessToken()
        else {return Fail<UploadChunkResponseModel, Error>(error: NetworkError.noAccessToken)
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
        let resources = Resources<UploadChunkResponseModel, UploadChunkRequestModel>(
            path: Constants.Endpoints.uploadFiles,
            requestType: .POST,
            bodyParameters: UploadChunkRequestModel(chunk: chunk, offset: offset, clientId: clientId),
            httpHeaderFields: ["accesstoken" : accessToken]) //access token
        
        return networkService.performRequest(resources: resources)
    }
    
    func verifyUpload(total: Int, size: Int, mimeType: String, fileName: String, clientId: String, fileHash: String, type: String, relationId: Int, metaData: MetaData) -> AnyPublisher<VerifyFileResponseModel, Error>{
        guard let accessToken = getAccessToken() else {
            return Fail<VerifyFileResponseModel, Error>(error: NetworkError.noAccessToken).receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
        
        let resources = Resources<VerifyFileResponseModel, VerifyFileRequestModel>(
            path: Constants.Endpoints.verifyFile,
            requestType: .POST,
            bodyParameters: VerifyFileRequestModel(total: total, size: size, mimeType: mimeType, fileName: fileName, type: type, fileHash: fileHash, relationId: relationId, clientId: clientId, metaData: metaData),
            httpHeaderFields: ["accesstoken" : accessToken])
        
        return networkService.performRequest(resources: resources)
    }
    
    func uploadWholeFile(fromUrl url: URL, mimeType: String, metaData: MetaData, specificFileName: String?) -> (AnyPublisher<(File?, CGFloat), Error>) {
        
        let chunkSize: Int = 1024 * 1024 // TODO: - determine best
        let clientId = UUID().uuidString
        var hasher = SHA256()
        var hash: String?
        let somePublisher = PassthroughSubject<(File?, CGFloat), Error>()
        
        guard FileManager.default.fileExists(atPath: url.path),
              let outputFileHandle = try? FileHandle(forReadingFrom: url),
              let resources = try? url.resourceValues(forKeys:[.fileSizeKey, .nameKey]),
              let fileSize = resources.fileSize
        else {
            return somePublisher.eraseToAnyPublisher()
        }
        let fileName = specificFileName ?? resources.name ?? "unknownName"
        
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
            } receiveValue: { [weak self] uploadChunkResponseModel in
                guard let self,
                      let uploadedCount = uploadChunkResponseModel.data?.uploadedChunks?.count else { return }
                let percent = CGFloat(uploadedCount) / CGFloat(totalChunks)
                somePublisher.send((nil, percent))
                
                if uploadedCount == totalChunks {
                    guard let hash = hash else { return }
                    
                    self.verifyUpload(total: totalChunks, size: fileSize, mimeType: mimeType, fileName: fileName, clientId: clientId, fileHash: hash, type: hash, relationId: 1, metaData: metaData).sink { [weak self] completion in
                        switch completion {
                            
                        case .finished:
                            break
                        case let .failure(error):
                            print("verifyUpload error: ", error)
                            somePublisher.send(completion: .failure(NetworkError.verifyFileFail))
                        }
                    } receiveValue: {  verifyFileResponse in
                        //                        print("verifyFile response", verifyFileResponse)
                        guard let file = verifyFileResponse.data?.file else { return }
                        somePublisher.send((file, 1))
                    }.store(in: &self.subs)
                }
            }.store(in: &subs)
            chunk = try? outputFileHandle.read(upToCount: chunkSize)
            chunkOffset += 1
        }
        
        try? outputFileHandle.close()
//        print("File reading complete")
        
        return somePublisher.eraseToAnyPublisher()
    }
}

extension AppRepository {
    func saveDataToFile(_ data: Data, name: String) -> URL? {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        guard let targetURL = documentsDirectory?.appendingPathComponent(name) else { return nil }
        do {
            if FileManager.default.fileExists(atPath: targetURL.path) {
                try FileManager.default.removeItem(at: targetURL)
            }
            try data.write(to: targetURL)
            return targetURL
        } catch(let err) {
            print(err.localizedDescription)
            return nil
        }
    }
    
    func copyFile(from fromURL: URL, name: String) -> URL? {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        guard let targetURL = documentsDirectory?
            .appendingPathComponent(name)
            .appendingPathExtension(fromURL.pathExtension)
        else { return nil }

        do {
            if FileManager.default.fileExists(atPath: targetURL.path) {
                try FileManager.default.removeItem(at: targetURL)
            }
            try FileManager.default.copyItem(at: fromURL, to: targetURL)
            return targetURL
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    func getFile(name: String) -> URL? {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        guard let targetURL = documentsDirectory?.appendingPathComponent(name),
              FileManager.default.fileExists(atPath: targetURL.path)
        else { return nil }
        return targetURL
    }
    
    func getFileData(localId: String?, context: NSManagedObjectContext) -> FileData? {
        databaseService.getFileData(localId: localId, context: context)
    }
}
