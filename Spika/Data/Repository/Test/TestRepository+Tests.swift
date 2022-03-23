//
//  TestRepository+Tests.swift
//  Spika
//
//  Created by Nikola Barbarić on 23.03.2022..
//

import Combine

extension TestRepository {
    func testnaRepo(naziv: String) -> Future<String, Error> {
        return Future { promise in
            promise(.failure(DatabseError.unknown))
        }
    }
}
