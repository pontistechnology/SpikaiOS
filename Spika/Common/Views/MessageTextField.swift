//
//  MessageTextField.swift
//  Spika
//
//  Created by Marko on 25.10.2021..
//

import UIKit

class MessageTextField: CustomTextField {
    override var inset: UIEdgeInsets {
        get {
            return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 38)
        }
        set {
            super.inset = newValue
        }
    }
}
