//
//  String+CryptoKit.swift
//  Spika
//
//  Created by Marko on 08.11.2021..
//

import Foundation
import CryptoKit
import UIKit

extension String {
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
    
    // TODO: check
    func getAvatarUrl() -> String? {
        if self.starts(with: "http") {
            return self
        } else if self.starts(with: "/") {
            return Constants.Networking.baseUrl + self.dropFirst()
        } else {
            return Constants.Networking.baseUrl + self
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
}
