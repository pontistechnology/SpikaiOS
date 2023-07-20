//
//  FetchedContact.swift
//  Spika
//
//  Created by Mislav Bagovic on 20.04.2022..
//

import Foundation

struct ContactFetchResult {
    var error: Error?
    var fetchedContacts: [FetchedContact]?
}

struct FetchedContact {
    var firstName: String?
    var lastName: String?
    var telephone: String!
}
