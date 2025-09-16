//
//  Message+Extensions.swift
//  Spika
//
//  Created by Nikola Barbarić on 20.10.2022..
//

import Foundation

extension Message {
    func getReuseIdentifier2() -> String? {
        let type = deleted ? "Deleted" : type.rawValue.capitalized
        return type + "MessageTableViewCell"
    }
}
