//
//  AppRepository+Notes.swift
//  Spika
//
//  Created by Nikola Barbarić on 07.08.2023..
//

import Foundation
import Combine

extension AppRepository {
    func getAllNotes(roomId: Int64) -> AnyPublisher<AllNotesResponseModel, Error> {
        guard let accessToken = getAccessToken() else { return
            Fail<AllNotesResponseModel, Error>(error: NetworkError.noAccessToken)
                    .receive(on: DispatchQueue.main)
                    .eraseToAnyPublisher()
        }
        
        let resources = Resources<AllNotesResponseModel, EmptyRequestBody>(
            path: Constants.Endpoints.allRoomNotes.appending("/\(roomId)"),
            requestType: .GET,
            bodyParameters: nil,
            httpHeaderFields: ["accesstoken" : accessToken]
        )
        
        return networkService.performRequest(resources: resources)
    }
    
    func updateNote(title: String, content: String, id: Int64) -> AnyPublisher<OneNoteResponseModel, Error> {
        guard let accessToken = getAccessToken() else { return
            Fail<OneNoteResponseModel, Error>(error: NetworkError.noAccessToken)
                    .receive(on: DispatchQueue.main)
                    .eraseToAnyPublisher()
        }
        
        let resources = Resources<OneNoteResponseModel, OneNoteRequestModel>(
            path: Constants.Endpoints.oneNote.appending("/\(id)"),
            requestType: .PUT,
            bodyParameters: OneNoteRequestModel(title: title,
                                                content: content),
            httpHeaderFields: ["accesstoken" : accessToken]
        )
        
        return networkService.performRequest(resources: resources)
    }
    
    func createNote(title: String, content: String, roomId: Int64) -> AnyPublisher<OneNoteResponseModel, Error> {
        guard let accessToken = getAccessToken() else { return
            Fail<OneNoteResponseModel, Error>(error: NetworkError.noAccessToken)
                    .receive(on: DispatchQueue.main)
                    .eraseToAnyPublisher()
        }
        
        let resources = Resources<OneNoteResponseModel, OneNoteRequestModel>(
            path: Constants.Endpoints.allRoomNotes.appending("/\(roomId)"),
            requestType: .POST,
            bodyParameters: OneNoteRequestModel(title: title,
                                                content: content),
            httpHeaderFields: ["accesstoken" : accessToken]
        )
        
        return networkService.performRequest(resources: resources)
    }
}
