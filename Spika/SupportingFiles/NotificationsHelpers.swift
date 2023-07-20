//
//  NotificationsHelpers.swift
//  Spika
//
//  Created by Nikola Barbarić on 12.04.2023..
//

import Foundation
import UIKit

class NotificationHelpers {
    func removeNotifications(withRoomId roomId: Int64) {
        UNUserNotificationCenter.current().getDeliveredNotifications { [weak self] notifications in
            let identifiers = notifications.filter { notification in
                guard let message = self?.decodeMessageFrom(userInfo: notification.request.content.userInfo) else { return false }
                return message.roomId == roomId
            }.map { $0.request.identifier }
            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: identifiers)
        }
    }
    
    func removeNotificationsThatAreNot(roomIds: [Int64]) {
        UNUserNotificationCenter.current().getDeliveredNotifications { [weak self] notifications in
            let identifiers = notifications.filter { notification in
                guard let message = self?.decodeMessageFrom(userInfo: notification.request.content.userInfo) else { return false }
                return !roomIds.contains(message.roomId)
            }.map { $0.request.identifier }
            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: identifiers)
        }
    }
    
    func decodeMessageFrom(userInfo: [AnyHashable : Any]) -> Message? {
        guard let messageData = userInfo["message"] as? String,
              let jsonData = messageData.data(using: .utf8),
              let message = try? JSONDecoder().decode(Message.self, from: jsonData)
        else {
            return nil
        }
        return message
    }
}
