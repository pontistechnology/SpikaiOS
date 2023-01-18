//
//  AppRepository.swift
//  Spika
//
//  Created by Marko on 06.10.2021..
//

import Foundation
import Combine
import CoreData

class AppRepository: Repository {
    let networkService: NetworkService
    let databaseService: DatabaseService
    var subs = Set<AnyCancellable>()
    let userDefaults: UserDefaults
    
    let unreadRoomsPublisher = CurrentValueSubject<Int,Never>(0)
    
    let writeQueue = DispatchQueue(label: "com.spika.blockeduserservice", attributes: .concurrent)
    
    let blockedUserIds = CurrentValueSubject<Set<Int64>?,Never>(nil)
    
    let confirmedUserIds = CurrentValueSubject<Set<Int64>?,Never>(nil)
    
    init(networkService: NetworkService, databaseService: DatabaseService, userDefaults: UserDefaults) {
        self.networkService = networkService
        self.databaseService = databaseService
        self.userDefaults = userDefaults
        self.loadStoredBlockedUserValues()
//        print("repo init")
    }
    
    deinit {
//        print("repo deinit")
    }
    
    func getAccessToken() -> String? {
        return userDefaults.string(forKey: Constants.Database.accessToken)
    }
    
    func getMyDeviceId() -> Int64 {
        return Int64(userDefaults.integer(forKey: Constants.Database.deviceId))
    }
    
    func getMainContext() -> NSManagedObjectContext {
        return databaseService.coreDataStack.mainMOC
    }
}
