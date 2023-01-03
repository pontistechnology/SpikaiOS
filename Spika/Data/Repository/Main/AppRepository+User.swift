//
//  AppRepository+User.swift
//  Spika
//
//  Created by Marko on 13.10.2021..
//

import UIKit
import Combine
import CryptoKit

extension AppRepository {
    
    // MARK: UserDefaults
    
    func saveUserInfo(user: User, device: Device? = nil) {
        userDefaults.set(user.id, forKey: Constants.Database.userId)
        userDefaults.set(user.telephoneNumber, forKey: Constants.Database.userPhoneNumber)
        userDefaults.set(user.displayName, forKey: Constants.Database.displayName)
        guard let device = device else { return }
        userDefaults.set(device.id, forKey: Constants.Database.deviceId)
        userDefaults.set(device.token, forKey: Constants.Database.accessToken)
    }
    
    func getMyUserId() -> Int64 {
        return Int64(userDefaults.integer(forKey: Constants.Database.userId))
    }
    
    // MARK: Network
    
    func fetchMyUserDetails() -> AnyPublisher<AuthResponseModel, Error> {
        let resources = Resources<AuthResponseModel, AuthRequestModel>(
            path: Constants.Endpoints.getUserDetails,
            requestType: .GET,
            bodyParameters: nil,
            httpHeaderFields: nil,
            queryParameters: nil
        )
        return networkService.performRequest(resources: resources)
    }
    
    func authenticateUser(telephoneNumber: String, deviceId: String) -> AnyPublisher<AuthResponseModel, Error> {
        print("Phone number SHA256: ", telephoneNumber.getSHA256())
        let resources = Resources<AuthResponseModel, AuthRequestModel>(
            path: Constants.Endpoints.authenticateUser,
            requestType: .POST,
            bodyParameters: AuthRequestModel(
                telephoneNumber: telephoneNumber,
                telephoneNumberHashed: telephoneNumber.getSHA256(),
                deviceId: deviceId),
            httpHeaderFields: nil,
            queryParameters: nil
        )
        return networkService.performRequest(resources: resources)
    }
    
    func verifyCode(code: String, deviceId: String) -> AnyPublisher<AuthResponseModel, Error> {
        let resources = Resources<AuthResponseModel, VerifyCodeRequestModel>(
            path: Constants.Endpoints.verifyCode,
            requestType: .POST,
            bodyParameters: VerifyCodeRequestModel(code: code, deviceId: deviceId),
            httpHeaderFields: nil,
            queryParameters: nil
        )
        print("resources are: ", resources)
        return networkService.performRequest(resources: resources)
    }
    
    func updateUser(username: String?, avatarFileId: Int64?, telephoneNumber: String?, email: String?) -> AnyPublisher<UserResponseModel, Error>{
        
        guard let accessToken = getAccessToken()
        else {return Fail<UserResponseModel, Error>(error: NetworkError.noAccessToken)
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
        let resources = Resources<UserResponseModel, UserRequestModel>(
            path: Constants.Endpoints.userInfo,
            requestType: .PUT,
            bodyParameters: UserRequestModel(telephoneNumber: telephoneNumber, emailAddress: email, displayName: username, avatarFileId: avatarFileId),
            httpHeaderFields: ["accesstoken" : accessToken])
        return networkService.performRequest(resources: resources)
    }
    
    func uploadWholeFile(data: Data) -> (AnyPublisher<(File?, CGFloat), Error>) {
        
        let dataLen: Int = data.count
        let chunkSize: Int = ((1024) * 4)
        let fullChunks = Int(dataLen / chunkSize)
        let totalChunks: Int = fullChunks + (dataLen % 1024 != 0 ? 1 : 0)
        let clientId = UUID().uuidString
        var hasher = SHA256()
        var hash: String?
        let somePublisher = PassthroughSubject<(File?, CGFloat), Error>()
        
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
                somePublisher.send((nil, percent))
                
                if uploadedCount == totalChunks {
                    guard let hash = hash else {
                        return
                    }
                    
                    self.verifyUpload(total: totalChunks, size: dataLen, mimeType: "image/*", fileName: "fileName", clientId: clientId, fileHash: hash, type: hash, relationId: 1, metaData: MetaData(width: 1, height: 1, duration: 1)).sink { [weak self] completion in
                        guard let _ = self else { return }
                        switch completion {
                            
                        case .finished:
                            break
                        case let .failure(error):
                            print("verifyUpload error: ", error)
                            somePublisher.send(completion: .failure(NetworkError.verifyFileFail))
                        }
                    } receiveValue: { [weak self] verifyFileResponse in
                        guard let _ = self else { return }
                        print("verifyFile response", verifyFileResponse)
                        guard let file = verifyFileResponse.data?.file else { return }
                        somePublisher.send((file, 1))
                    }.store(in: &self.subs)
                }
            }.store(in: &subs)
        }
        
        return somePublisher.eraseToAnyPublisher()
    }
    
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
    
    func postContacts(hashes: [String]) -> AnyPublisher<ContactsResponseModel, Error> {
        guard let accessToken = getAccessToken()
        else { return Fail<ContactsResponseModel, Error>(error: NetworkError.noAccessToken)
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
        let contacts = ContactsRequestModel(contacts: hashes)
        let resources = Resources<ContactsResponseModel, ContactsRequestModel>(
            path: Constants.Endpoints.contacts,
            requestType: .POST,
            bodyParameters: contacts,
            httpHeaderFields: ["accesstoken" : accessToken])
        return networkService.performRequest(resources: resources)
    }
    
    func getContacts(page: Int) -> AnyPublisher<ContactsResponseModel, Error> {
        guard let accessToken = getAccessToken()
        else { return Fail<ContactsResponseModel, Error>(error: NetworkError.noAccessToken)
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
        let resources = Resources<ContactsResponseModel, EmptyRequestBody>(
            path: Constants.Endpoints.contacts,
            requestType: .GET,
            bodyParameters: nil,
            httpHeaderFields: ["accesstoken" : accessToken],
            queryParameters: ["page": String(page)]
        )
        return networkService.performRequest(resources: resources)
    }
    
    // MARK: Database
    
    func getLocalUsers() -> Future<[User], Error> {
        return databaseService.userEntityService.getLocalUsers()
    }
    
    func getLocalUser(withId id: Int64) -> Future<User, Error> {
        return databaseService.userEntityService.getLocalUser(withId: id)
    }
    
    func saveUser(_ user: User) -> Future<User, Error> {
        return databaseService.userEntityService.saveUser(user)
    }
    
    func saveUsers(_ users: [User]) -> Future<[User], Error> {
        return databaseService.userEntityService.saveUsers(users)
    }
    
    func saveContacts(_ contacts: [FetchedContact]) -> Future<[FetchedContact], Error> {
        return databaseService.userEntityService.saveContacts(contacts)
    }
    
    func getContact(phoneNumber: String) -> Future<FetchedContact, Error> {
        return databaseService.userEntityService.getContact(phoneNumber: phoneNumber)
    }
    
    func updateUsersWithContactData(_ users: [User]) -> Future<[User], Error> {
        return databaseService.userEntityService.updateUsersWithContactData(users)
    }
    
    
    @available(iOSApplicationExtension 13.4, *)
    func uploadWholeFile(fromUrl url: URL) -> (AnyPublisher<(File?, CGFloat), Error>) {
        
        let chunkSize: Int = 1024 * 4
        let clientId = UUID().uuidString
        var hasher = SHA256()
        var hash: String?
        let somePublisher = PassthroughSubject<(File?, CGFloat), Error>()
        
        guard FileManager.default.fileExists(atPath: url.path),
              let outputFileHandle = try? FileHandle(forReadingFrom: url),
              let resources = try? url.resourceValues(forKeys:[.fileSizeKey]),
              let fileSize = resources.fileSize,
              let fileName = resources.name
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
            } receiveValue: { [weak self] uploadChunkResponseModel in
                guard let self = self,
                      let uploadedCount = uploadChunkResponseModel.data?.uploadedChunks?.count else { return }
                let percent = CGFloat(uploadedCount) / CGFloat(totalChunks)
                somePublisher.send((nil, percent))
                
                if uploadedCount == totalChunks {
                    guard let hash = hash else { return }
                    
                    self.verifyUpload(total: totalChunks, size: fileSize, mimeType: "image/*", fileName: "fileName", clientId: clientId, fileHash: hash, type: hash, relationId: 1, metaData: MetaData(width: 2, height: 2, duration: 2)).sink { [weak self] completion in
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
        print("File reading complete")
        
        return somePublisher.eraseToAnyPublisher()
    }
}
