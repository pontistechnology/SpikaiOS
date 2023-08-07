//
//  String+CryptoKit.swift
//  Spika
//
//  Created by Marko on 08.11.2021..
//

import Foundation
import CryptoKit
import UIKit
import CoreTelephony

extension String {
    static func getStringFor(_ value: Constants.Strings) -> String {
        return NSLocalizedString(value.rawValue, comment: value.rawValue)
    }
    
    func getSHA256() -> String {
        let data = Data(self.utf8)
        let dataHashed = SHA256.hash(data: data)
        return dataHashed.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    func idealSizeForMessage(font: UIFont, maximumWidth: CGFloat) -> CGSize {
        let oneLineHeight = "W".height(withConstrainedWidth: maximumWidth, font: font)
        let textHeight = self.height(withConstrainedWidth: maximumWidth, font: font)
        if textHeight == oneLineHeight {
            let oneLineMinimumWidth = self.width(withConstrainedHeight: oneLineHeight, font: font)
            return CGSize(width: oneLineMinimumWidth, height: oneLineHeight)
        } else {
            return CGSize(width: maximumWidth, height: textHeight)
        }
    }
    
    private func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        return ceil(boundingBox.height)
    }
    
    private func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
            let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font : font], context: nil)

            return ceil(boundingBox.width)
    }
    
    func getFullUrl() -> URL? {
        if self.starts(with: "http") {
            return URL(string: self)
        } else if self.starts(with: "/") {
            return URL(string: Constants.Networking.baseUrl + self.dropFirst())
        } else {
            return URL(string: Constants.Networking.baseUrl + self)
        }
    }
    
    func firstLetter() -> String {
        String(self.first ?? "#")
    }
    
    var isNumber: Bool {
        return self.allSatisfy { character in
            character.isNumber
        }
    }
    
    // Get a user's default region code
    ///
    /// - returns: A computed value for the user's current region - based on the iPhone's carrier and if not available, the device region.
    static func defaultRegionCode() -> String? {
#if os(iOS) && !targetEnvironment(simulator) && !targetEnvironment(macCatalyst)
        if let isoCountryCode = CTTelephonyNetworkInfo().serviceSubscriberCellularProviders?.values.first?.isoCountryCode {
            return isoCountryCode.uppercased()
        }
#endif
        if let countryCode = Locale.current.regionCode {
            return countryCode.uppercased()
        }
        return nil
    }
}
