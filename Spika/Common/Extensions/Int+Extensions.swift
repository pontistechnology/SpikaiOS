//
//  Int+Extensions.swift
//  Spika
//
//  Created by Nikola Barbarić on 24.04.2022..
//

import Foundation

extension Int {
    func convertTimestampToHoursAndMinutes() -> String {
        print("vrijeme: ", self)
        let d = Double(self) / 1000 // TODO: check. Device and server timestamp is not same
        let date = Date(timeIntervalSince1970: d)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm" //Specify your format that you want
        return dateFormatter.string(from: date)
    }
}
