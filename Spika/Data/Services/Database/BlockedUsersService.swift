//
//  BlockedUsersService.swift
//  Spika
//
//  Created by Vedran Vugrin on 12.01.2023..
//

import Foundation
import Combine

class BlockedUsersService {
    //MARK: Not thread safe, perhaps not necessary?
    let blockedUserIds = CurrentValueSubject<[User]?,Never>(nil)
    
    let sharedPrefs: UserDefaults
    
    init(sharedPrefs: UserDefaults) {
        self.sharedPrefs = sharedPrefs
        
        guard let data = sharedPrefs.value(forKey: "blocked_ids") as? Data  else { return }
        let decoder = JSONDecoder()
        let users = try? decoder.decode([User].self, from: data)
        
        self.blockedUserIds.send(users)
    }
    
    func updateBlockedIds(blockedUsers: [User]?) {
        let encoder = JSONEncoder()
        let data = try? encoder.encode(blockedUsers)
        
        sharedPrefs.setValue(data, forKey: "blocked_ids")
        blockedUserIds.send(blockedUsers)
    }
    
}
