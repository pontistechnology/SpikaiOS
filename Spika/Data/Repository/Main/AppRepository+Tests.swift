//
//  AppRepository+Tests.swift
//  Spika
//
//  Created by Nikola Barbarić on 23.03.2022..
//

import Combine

extension AppRepository {
    
    func testnaRepo(naziv: String) -> Future<String, Error> {
        return databaseService.testEntityService.testSavingUser(test: naziv)
    }
}
