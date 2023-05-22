//
//  DatabaseService+DeviceContacts.swift
//  Spika
//
//  Created by Vedran Vugrin on 22.05.2023..
//

import Contacts
import CoreTelephony
import PhoneNumberKit

class PhoneNumberParser {
    
    let phoneNumberKit = PhoneNumberKit()
    
    public func parse(_ numberStrings: [String]) -> [String] {
        return self.phoneNumberKit.parse(numberStrings).map {  self.phoneNumberKit.format($0, toType: .e164, withPrefix: true) }
    }
    
}
