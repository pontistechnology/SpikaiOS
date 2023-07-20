//
//  Data+Extension.swift
//  Spika
//
//  Created by Nikola Barbarić on 28.02.2022..
//

import Foundation
import CryptoKit

extension Data {
    
    func getSHA256() -> String {
        return SHA256.hash(data: self).compactMap { String(format: "%02x", $0)}.joined()
    }
    
}
