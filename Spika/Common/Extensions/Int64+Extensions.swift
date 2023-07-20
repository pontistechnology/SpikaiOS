//
//  Int+Extensions.swift
//  Spika
//
//  Created by Nikola Barbarić on 24.04.2022..
//

import Foundation

enum DateFormat: String {
    case HHmm, ddMMyyyyHHmm, ddMM, allChatsTimeFormat, messageDetailsTimeFormat, ddMMyyyy
    
    var format: String {
        switch self {
        case .HHmm:
            return "HH:mm"
        case .ddMMyyyyHHmm:
            return "dd.MM.yyyy. HH:mm"
        case .ddMM:
            return "dd.MM."
        case .allChatsTimeFormat:
            return "calculate"
        case .messageDetailsTimeFormat:
            return "dd.MM.yyyy. HH:mm"
        case .ddMMyyyy:
            return "dd.MM.yyyy."
        }
    }
}

extension Int64 {
    
    func convert(to format: DateFormat) -> String {
        switch format {
        case .HHmm:
            return convertTimestamp(to: .HHmm)
        case .ddMMyyyyHHmm:
            return convertTimestamp(to: .ddMMyyyyHHmm)
        case .allChatsTimeFormat:
            if self.isToday() {
                return convertTimestamp(to: .HHmm)
            } else if self.isThisYear() {
                return convertTimestamp(to: .ddMM)
            } else {
                return convertTimestamp(to: .ddMMyyyy)
            }
        case.messageDetailsTimeFormat:
            return convertTimestamp(to: .messageDetailsTimeFormat)
        case .ddMM:
            return convertTimestamp(to: .ddMM)
        case .ddMMyyyy:
            return convertTimestamp(to: .ddMMyyyy)
        }
    }
    
    private func convertTimestamp(to dateFormat: DateFormat) -> String {
        let d = Double(self) / 1000
        let date = Date(timeIntervalSince1970: d)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat.format
        return dateFormatter.string(from: date)
    }
    
    func isToday() -> Bool {
        return Calendar.current.isDateInToday(Date(timeIntervalSince1970: Double(self)/1000))
    }
    
    func isThisYear() -> Bool {
        return Calendar.current.isDate(Date(timeIntervalSince1970: Double(self)/1000), equalTo: Date(), toGranularity: .year)
    }
}

// MARK: - File path

extension Int64 {
    func fullFilePathFromId() -> URL? {
        let s = "api/upload/files/" + "\(self)"
        return s.getFullUrl()
    }
}
