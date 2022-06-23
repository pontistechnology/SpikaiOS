//
//  Date+Extensions.swift
//  Spika
//
//  Created by Nikola Barbarić on 23.06.2022..
//

import Foundation

extension Date {
    func currentTimeMillis() -> Int64 {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
}
