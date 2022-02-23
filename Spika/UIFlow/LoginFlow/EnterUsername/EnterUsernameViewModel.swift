//
//  EnterUsernameViewModel.swift
//  Spika
//
//  Created by Nikola Barbarić on 25.01.2022..
//

import Combine
import Foundation
import UIKit
import CryptoKit

class EnterUsernameViewModel: BaseViewModel {
    
    let isUsernameWrong = CurrentValueSubject<Bool, Never>(true)
    
    
    func updateUsername(username: String) {
        networkRequestState.send(.started)
        repository.updateUsername(username: username).sink { [weak self] completion in
            self?.networkRequestState.send(.finished)
            switch completion {
            case let .failure(error):
                print("updateUsername error: ", error)
            default:
                break
            }
        } receiveValue: { response in
//            print("Uspjesno: ", response.data?.user.displayName)
        }.store(in: &subscriptions)

    }
    
    func testUploadWhole(data: Data) {
        repository.uploadWholeFile(data: data)
    }
    
    func uploadPhoto(data: Data) {
        
        let dataLen: Int = data.count
        let chunkSize: Int = ((1024) * 4)
        let fullChunks = Int(dataLen / chunkSize)
        let totalChunks: Int = fullChunks + (dataLen % 1024 != 0 ? 1 : 0)
        print("there will be total chunks: ", totalChunks)
        
        let fileHash = data.getSHA256()
        print("data hash viewmodel: ", fileHash)
        
        for chunkCounter in 0..<totalChunks {
          var chunk:Data
          let chunkBase: Int = chunkCounter * chunkSize
          var diff = chunkSize
          if(chunkCounter == totalChunks - 1) {
            diff = dataLen - chunkBase
          }
            
          let range:Range<Data.Index> = chunkBase..<(chunkBase + diff)
          chunk = data.subdata(in: range)

        networkRequestState.send(.started)
        repository.uploadChunk(chunk: chunk.base64EncodedString(), offset: chunkBase/chunkSize, total: totalChunks, size: dataLen, mimeType: "image/*", fileName: "profilePhoto", clientId: "coki011", type: "avatar", fileHash: fileHash, relationId: 1)
                .sink { [weak self] completion in
                self?.networkRequestState.send(.finished)
                switch completion {
                case let .failure(bhhh):
                    print("error", bhhh)
                default:
                    break
                }
            } receiveValue: { response in
//                print("Response Upload File: ", response.data?.uploadedChunks?.count)
                print("response: ", response)
            }.store(in: &subscriptions)

        }
    }
}
