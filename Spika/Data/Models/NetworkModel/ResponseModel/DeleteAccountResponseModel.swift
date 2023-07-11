//
//  DeleteAccountResponseModel.swift
//  Spika
//
//  Created by Nikola Barbarić on 10.07.2023..
//

import Foundation

struct DeleteAccountResponseModel: Codable {
    let status: String?
    let data: IsDeletedData?
    let error: String?
    let message: String?
}

// MARK: - DataClass
struct IsDeletedData: Codable {
    let deleted: Bool
}
