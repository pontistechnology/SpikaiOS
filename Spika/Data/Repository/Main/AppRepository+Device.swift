//
//  AppRepository+Device.swift
//  Spika
//
//  Created by Nikola Barbarić on 25.04.2022..
//

import Combine
import Foundation
import UIKit

extension AppRepository {
    
    // MARK: NETWORKING
    
    func updatePushToken() -> AnyPublisher<UpdatePushResponseModel, Error> {
        guard let accessToken = getAccessToken(),
              let token = userDefaults.string(forKey: Constants.Database.pushToken)
        else {return Fail<UpdatePushResponseModel, Error>(error: NetworkError.noAccessToken)
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
        
        let resources = Resources<UpdatePushRequestModel>(
            path: Constants.Endpoints.updatePush,
            requestType: .PUT,
            bodyParameters: UpdatePushRequestModel(pushToken: token),
            httpHeaderFields: ["accesstoken" : accessToken])
        
        return networkService.performRequest(resources: resources)
    }
    
    // MARK: - Notifications
    
    func removeNotificationsWith(roomId: Int64) {
        notificationHelpers.removeNotifications(withRoomId: roomId)
    }
    
    // MARK: - Themes
    
    func saveSelectedTheme(_ theme: String) {
        userDefaults.set(theme, forKey: Constants.Database.selectedTheme)
    }
}
