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
        self.font = .customFont(name: .MontserratMedium, size: 26)
        textColor = .textPrimary
//        textContentType = .oneTimeCode
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
