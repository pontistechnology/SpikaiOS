////
////  TestRepository+BlockedUsers.swift
////  Spika
////
////  Created by Vedran Vugrin on 18.01.2023..
////
//
//import Foundation
//import Combine
//
//extension TestRepository {
//
//    func updateBlockedUsers(users: [User]) {}
//
//    func updateConfirmedUsers(confirmedUsers: [User]) {}
//
//    func getBlockedUsers() -> AnyPublisher<BlockedUsersResponseModel, Error> {
//        return Fail<BlockedUsersResponseModel, Error>(error: NetworkError.noAccessToken)
//                .receive(on: DispatchQueue.main)
//                .eraseToAnyPublisher()
//    }
//
//    func blockedUsersPublisher() -> CurrentValueSubject<Set<Int64>?,Never> {
//        return CurrentValueSubject(nil)
//    }
//
//    func confirmedUsersPublisher() -> CurrentValueSubject<Set<Int64>?,Never> {
//        return CurrentValueSubject(nil)
//    }
//
//}
