//
//  TelephoneNumber.swift
//  Spika
//
//  Created by Nikola Barbarić on 01.04.2023..
//

import Foundation

struct TelephoneNumber {
    let countryCode: String
    let restOfNumber: String
    
    func getFullNumber() -> String {
        countryCode + restOfNumber
    }
}
