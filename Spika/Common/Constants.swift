//
//  Constants.swift
//  Spika
//
//  Created by Marko on 06.10.2021..
//

import Foundation

struct Constants {
    struct Strings {
        static let appName = "Spika"
        static let cancel = "Cancel"
    }
    
    struct Networking {
        static let baseUrl = "https://spika3dev.spika.chat/"
    }
    
    struct Endpoints {
        static let getPosts = "posts"
        static let authenticateUser = "api/messenger/auth"
        static let verifyCode = "api/messenger/auth/verify"
    }
    
    struct Database {
        static let databaseName = "CoreDatabase"
        static let userEntity = "UserEntity"
        static let chatEntity = "ChatEntity"
        static let messageEntity = "MessageEntity"
    }
    
    struct Colors {
        static let appBlueLight = "appBlueLight"
        static let appBlue = "appBlue"
        static let appGray = "appGray"
        static let appLightGray = "appLightGray"
        static let textTertiary = "textTertiary"
        static let textPrimary = "textPrimary"
        static let textBlue = "textBlue"
        static let appMediumGray = "appMediumGray"
        static let appRedLight = "appRedLight"
        static let appRed = "appRed"
    }
    
    struct UserDefaults {
        static let userId = "userId"
        static let userPhoneNumber = "userPhoneNumber"
        static let deviceId = "deviceId"
        static let token = "token"
    }
    
}
