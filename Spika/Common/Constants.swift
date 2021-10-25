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
        static let baseUrl = "https://jsonplaceholder.typicode.com/"
    }
    
    struct Endpoints {
        static let getPosts = "posts"
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
    }
    
}
