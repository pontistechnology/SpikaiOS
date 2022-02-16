//
//  String+CryptoKit.swift
//  Spika
//
//  Created by Marko on 08.11.2021..
//

import Foundation
import CryptoKit

extension String {
    func getSHA256() -> String {
        let data = Data(self.utf8)
        let dataHashed = SHA256.hash(data: data)
        return dataHashed.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    
    func getMD5() -> String {
        let data = Data(self.utf8)
        return Insecure.MD5
            .hash(data: data)
            .map {String(format: "%02x", $0)}
            .joined()
    }
    
}

extension Data {
    
    func getSHA256() -> String {
        return SHA256.hash(data: self).compactMap { String(format: "%02x", $0)}.joined()
    }
    
}
