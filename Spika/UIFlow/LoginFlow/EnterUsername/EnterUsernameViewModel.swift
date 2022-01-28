//
//  EnterUsernameViewModel.swift
//  Spika
//
//  Created by Nikola Barbarić on 25.01.2022..
//

import Combine
import Foundation
import UIKit

class EnterUsernameViewModel: BaseViewModel {
    
    let isUsernameWrong = CurrentValueSubject<Bool, Never>(true)
    
    func updateUsername(username: String) {
        print("os version", UIDevice.current.systemVersion)
        print("device name", UIDevice.current.name)
        print("name neki", UIDevice.current.systemName)
        print("language", Locale.current.languageCode)
        print("app version", Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? "dont know")
        
    }
}
