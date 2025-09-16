//
//  AllNotesResponseModel.swift
//  Spika
//
//  Created by Nikola Barbarić on 07.08.2023..
//

import Foundation

enum NoteState {
    case creatingNew(roomId: Int64)
    case viewing(note: Note)
    case editing(note: Note)
    
    var buttonTitle: String {
        switch self {
        case .creatingNew, .editing:
            return "Save"
        case .viewing:
            return "Edit"
        }
    }
    
    var isEditable: Bool {
        switch self {
        case .creatingNew, .editing:
            return true
        case .viewing:
            return false
        }
    }
    
    var note: Note? {
        switch self {
        case .creatingNew:
            return nil
        case .viewing(let note):
            return note
        case .editing(let note):
            return note
        }
    }
}

struct AllNotesResponseModel: Codable {
    let status: String?
    let data: AllNotesData?
    let error: String?
    let message: String?
}

// MARK: - DataClass
struct AllNotesData: Codable {
    let notes: [Note]?
}

struct Note: Codable {
    let id: Int64
    var title: String
    var content: String
    let roomId: Int64
    let createdAt: Int64
    let modifiedAt: Int64?
}
