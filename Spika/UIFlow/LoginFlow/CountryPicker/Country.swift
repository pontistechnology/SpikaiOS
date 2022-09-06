//
//  Country.swift
//  Spika
//
//  Created by Marko on 27.10.2021..
//

import UIKit

public struct Country: Hashable {
    public let name: String
    public let code: String
    public let phoneCode: String
    public func localizedName(_ locale: Locale = Locale.current) -> String? {
        return locale.localizedString(forRegionCode: code)
    }
    public var flag: UIImage {
        // Cocoapods || SPM
        return UIImage.safeImage(named: code.uppercased())
    }
}
