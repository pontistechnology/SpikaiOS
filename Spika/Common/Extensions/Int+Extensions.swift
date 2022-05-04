//
//  Int+Extensions.swift
//  Spika
//
//  Created by Nikola Barbarić on 24.04.2022..
//

import Foundation

extension Int {
    func convertTimestampToHoursAndMinutes() -> String {
        let d = Double(self) / 1000
        let date = Date(timeIntervalSince1970: d)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: date)
    }
}
