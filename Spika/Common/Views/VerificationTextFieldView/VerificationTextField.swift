//
//  VerificationTextField.swift
//  Spika
//
//  Created by Marko on 28.10.2021..
//

import UIKit

public protocol VerificationTextFieldDelegate: AnyObject {
    func deleteBackward(sender: VerificationTextField, previousValue: String?)
}

open class VerificationTextField: UITextField {
    
    weak open var deleteDelegate: VerificationTextFieldDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        textAlignment = .center
        autocapitalizationType = .none
        font = UIFont(name: "Montserrat-Medium", size: 26)
        textColor = UIColor(named: Constants.Colors.textPrimary)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func deleteBackward() {
        let prevValue = text
        super.deleteBackward()
        deleteDelegate?.deleteBackward(sender: self, previousValue: prevValue)
    }
    
}
