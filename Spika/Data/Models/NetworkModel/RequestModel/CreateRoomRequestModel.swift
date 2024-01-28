//
//  CreateRoomRequestModel.swift
//  Spika
//
//  Created by Nikola Barbarić on 07.03.2022..
//

import Foundation

struct CreateRoomRequestModel: Codable {
    var name: String?
    var avatarFileId: Int64?
    var userIds: [Int64]?
    var adminUserIds: [String]?
}

struct EditRoomRequestModel: Encodable {
    var action: String
    var userIds: [Int64]?
    var adminUserIds: [Int64]?
    var avatarFileId: Int64?
    var name: String?
    
    init(action: UpdateRoomAction) {
        self.action = action.action
        switch action {
        case .addGroupUsers(let userIds):
            self.userIds = userIds
        case .removeGroupUsers(let userIds):
            self.userIds = userIds
        case .addGroupAdmins(let userIds):
            self.adminUserIds = userIds
        case .removeGroupAdmins(let userIds):
            self.adminUserIds = userIds
        case .changeGroupName(let newName):
            self.name = newName
        case .changeGroupAvatar(let fileId):
            self.avatarFileId = fileId
        }
    }
}
