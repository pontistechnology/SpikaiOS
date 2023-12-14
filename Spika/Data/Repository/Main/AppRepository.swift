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
    
    var manualContactTrigger: PassthroughSubject<Void,Error>?
    var contactsLastSynced = Date()
    
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
    
    func getSelectedTheme() -> String {
        userDefaults.string(forKey: Constants.Database.selectedTheme) ?? "none"
    }
    
    func getAppModeIsTeamChat() -> Future<Bool?, Error> {
        return Future { [unowned self] promise in
            guard let settings = self.userDefaults.object(forKey: Constants.Database.serverSettings) as? Data,
                  let settings = try? JSONDecoder().decode(ServerSettingsModel.self, from: settings) else {
                self.getServerSettings()
                    .sink { c in
                        if case .failure(let error) = c {
                            promise(.failure(error))
                        }
                    } receiveValue: { [unowned self] apiSettings in
                        guard let data = apiSettings.data else {
                            promise(.success(nil))
                            return
                        }
                        promise(.success(data.teamMode))
                        guard let encoded = try? JSONEncoder().encode(data) else { return }
                        self.userDefaults.setValue(encoded, forKey: Constants.Database.serverSettings)
                    }
                    .store(in: &self.subs)
                return
            }
            promise(.success(settings.teamMode))
        }
    }
    
    func getServerSettings() -> AnyPublisher<ServerSettingsResponseModel, Error> {
        let resources = Resources<ServerSettingsResponseModel, EmptyRequestBody>(
            path: Constants.Endpoints.messengerSettings,
            requestType: .GET,
            bodyParameters: nil,
            httpHeaderFields: nil)
        
        return networkService.performRequest(resources: resources)
    }
    
    func deleteLocalDatabase() {
        databaseService.deleteEverything()
    }
    
    func deleteUserDefaults() {
        userDefaults.dictionaryRepresentation().forEach { key, value in
            userDefaults.removeObject(forKey: key)
        }
    }
    
    func deleteAllFiles() {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
              let fileUrls = try? FileManager.default.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil)
        else { return }
        for fileUrl in fileUrls {
            try? FileManager.default.removeItem(at: fileUrl)
        }
    }
}
