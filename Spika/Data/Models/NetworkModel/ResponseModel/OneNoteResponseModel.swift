//
//  OneNoteResponseModel.swift
//  Spika
//
//  Created by Nikola Barbarić on 07.08.2023..
//

import Foundation

struct OneNoteResponseModel: Codable {
    let status: String?
    let data: OneNoteData?
    let error: String?
    let message: String?
}

// MARK: - DataClass
struct OneNoteData: Codable {
    let note: Note?
}
