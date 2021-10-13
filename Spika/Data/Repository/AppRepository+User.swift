//
//  AppRepository+User.swift
//  Spika
//
//  Created by Marko on 13.10.2021..
//

import Foundation
import Combine

extension AppRepository {
    func getUsers() -> Future<[User], Error> {
        return databaseService.userEntityService.getUsers()
    }
    
    func saveUser(_ user: User) -> Future<User, Error> {
        return databaseService.userEntityService.saveUser(user)
    }
    
}
