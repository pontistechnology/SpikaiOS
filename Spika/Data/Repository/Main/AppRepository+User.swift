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
        let defaults = UserDefaults.standard
        defaults.set(user.id, forKey: Constants.UserDefaults.userId)
        defaults.set(user.telephoneNumber, forKey: Constants.UserDefaults.userPhoneNumber)
        defaults.set(user.displayName, forKey: Constants.UserDefaults.displayName)
        guard let device = device else { return }
        defaults.set(device.id, forKey: Constants.UserDefaults.deviceId)
        defaults.set(device.token, forKey: Constants.UserDefaults.accessToken)
    }
    
    func getMyUserId() -> Int {
        return UserDefaults.standard.integer(forKey: Constants.UserDefaults.userId)
    }
    
    // MARK: Network
    
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
    
    func updateUser(username: String?, avatarURL: String?, telephoneNumber: String?, email: String?) -> AnyPublisher<UserResponseModel, Error>{
        
        guard let accessToken = getAccessToken()
        else {return Fail<UserResponseModel, Error>(error: NetworkError.noAccessToken)
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
        let resources = Resources<UserResponseModel, UserRequestModel>(
            path: Constants.Endpoints.userInfo,
            requestType: .PUT,
            bodyParameters: UserRequestModel(telephoneNumber: telephoneNumber, emailAddress: email, displayName: username, avatarUrl: avatarURL),
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
            
            uploadChunk(chunk: chunk.base64EncodedString(), offset: chunkBase/chunkSize, clientId: clientId).sink { completion in
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
                somePublisher.send((nil, percent))
                
                if uploadedCount == totalChunks {
                    guard let hash = hash else {
                        return
                    }

                    self.verifyUpload(total: totalChunks, size: dataLen, mimeType: "image/*", fileName: "fileName", clientId: clientId, fileHash: hash, type: hash, relationId: 1).sink { completion in
                        switch completion {
                            
                        case .finished:
                            break
                        case let .failure(error):
                            print("verifyUpload error: ", error)
                            somePublisher.send(completion: .failure(NetworkError.verifyFileFail))
                        }
                    } receiveValue: { verifyFileResponse in
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
    
    func verifyUpload(total: Int, size: Int, mimeType: String, fileName: String, clientId: String, fileHash: String, type: String, relationId: Int) -> AnyPublisher<VerifyFileResponseModel, Error>{
        guard let accessToken = getAccessToken() else {
            return Fail<VerifyFileResponseModel, Error>(error: NetworkError.noAccessToken).receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
        
        let resources = Resources<VerifyFileResponseModel, VerifyFileRequestModel>(
            path: Constants.Endpoints.verifyFile,
            requestType: .POST,
            bodyParameters: VerifyFileRequestModel(total: total, size: size, mimeType: mimeType, fileName: fileName, type: type, fileHash: fileHash, relationId: relationId, clientId: clientId),
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
    
    // MARK: Database // TODO: CDStack change
    
    func getUsers() -> Future<[LocalUser], Error> {
        return databaseService.getUsers()
    }
    
    func saveUser(_ user: LocalUser) -> Future<LocalUser, Error> {
        return databaseService.saveUser(user)
    }
    
    func saveUsers(_ users: [LocalUser]) -> Future<[LocalUser], Error> {
        return databaseService.saveUsers(users)
    }
}
