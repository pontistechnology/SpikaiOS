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
    let notificationHelpers = NotificationHelpers()
    let phoneNumberParser: PhoneNumberParser
    
    init(networkService: NetworkService,
         databaseService: DatabaseService,
         userDefaults: UserDefaults,
         phoneNumberParser: PhoneNumberParser) {
        self.networkService = networkService
        self.databaseService = databaseService
        self.userDefaults = userDefaults
        self.phoneNumberParser = phoneNumberParser
    }
    
    deinit {
//        print("repo deinit")
    }
    
    func getAccessToken() -> String? {
        return userDefaults.string(forKey: Constants.Database.accessToken)
    }
    
    func getMyDeviceId() -> String? {
        return userDefaults.string(forKey: Constants.Database.deviceId)
    }
    
    func getMainContext() -> NSManagedObjectContext {
        return databaseService.coreDataStack.mainMOC
    }
    
    func getCurrentAppereance() -> Int {
        return userDefaults.integer(forKey: Constants.Database.selectedAppereanceMode)
    }
    
}
