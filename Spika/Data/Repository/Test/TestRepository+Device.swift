////
////  TestRepository+Device.swift
////  Spika
////
////  Created by Nikola Barbarić on 25.04.2022..
////
//
//import Foundation
//import Combine
//
//extension TestRepository {
//    func updatePushToken() -> AnyPublisher<UpdatePushResponseModel, Error> {
//        return Fail<UpdatePushResponseModel, Error>(error: NetworkError.unknown)
//                .receive(on: DispatchQueue.main)
//                .eraseToAnyPublisher()
//    }
//}
