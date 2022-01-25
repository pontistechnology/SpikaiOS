//
//  VerifyCodeRequest.swift
//  Spika
//
//  Created by Marko on 28.10.2021..
//

import Foundation

struct VerifyCodeRequest: Codable {
    let code: String
    let deviceId: String
}
