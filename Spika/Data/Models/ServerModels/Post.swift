//
//  Post.swift
//  Spika
//
//  Created by Marko on 06.10.2021..
//

import Foundation

struct Post: Codable {
    let userId: Int
    let id: Int
    let title: String
    let body: String
}
