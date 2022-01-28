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
        
    }
}
