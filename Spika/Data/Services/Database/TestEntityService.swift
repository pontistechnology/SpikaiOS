//
//  TestEntityService.swift
//  Spika
//
//  Created by Nikola Barbarić on 23.03.2022..
//

import CoreData
import Combine

class TestEntityService {
    var managedContext = CoreDataManager.shared.managedContext
    
    func testSavingUser(test: String) -> Future<String, Error> {
        let a = TestEntity(context: managedContext)
        a.testAttribute = "AJMEda"
        
        do {
            try managedContext.save()
            return Future { promise in promise(.success(test))}
        } catch let error as NSError {
            return Future { promise in promise(.failure(error))}
        }
    }
}
