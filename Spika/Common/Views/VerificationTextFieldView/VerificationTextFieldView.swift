//
//  VerificationTextFieldView.swift
//  Spika
//
//  Created by Marko on 28.10.2021..
//

import UIKit

protocol VerificationTextFieldViewDelegate: AnyObject {
    func verificationTextFieldView(_ verificationTextFieldView: VerificationTextFieldView, valueDidChange code: String) -> Bool
    //func verificationTextFieldView(_ verificationTextFieldView: VerificationTextFieldView, valueDidChange code: String)
}

class VerificationTextFieldView: UIControl, BaseView {
    
    private var stackView = UIStackView()
    
    let length: Int
    var items: [VerificationTextFieldItem] = []
    open weak var delegate: VerificationTextFieldViewDelegate?
    var code: String {
        get {
            let items = stackView.arrangedSubviews.map({$0 as! VerificationTextFieldItem})
            let values = items.map({$0.textField.text ?? ""})
            return values.joined()
        }
        set {
            let array = newValue.map(String.init)
            for i in 0..<length {
                let item = stackView.arrangedSubviews[i] as! VerificationTextFieldItem
                item.textField.text = i < array.count ? array[i] : ""
            }
            if !stackView.arrangedSubviews.compactMap({$0 as? UITextField}).filter({$0.isFirstResponder}).isEmpty {
                _ = self.becomeFirstResponder()
            }
        }
    }
    
    init(length: Int) {
        self.length = length
        super.init(frame: .zero)
        setupView()
        generateItems()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        addSubview(stackView)
    }
    
    func styleSubviews() {
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        stackView.frame = self.bounds
        
        stackView.arrangedSubviews.forEach{($0.removeFromSuperview())}
    }
    
    func positionSubviews() {
        stackView.fillSuperview()
    }
    
    private func generateItems() {
        stackView.arrangedSubviews.forEach{($0.removeFromSuperview())}
        for i in 0..<length {
            let itemView = VerificationTextFieldItem()
            itemView.textField.deleteDelegate = self
            itemView.textField.delegate = self
            itemView.tag = i
            itemView.textField.tag = i
            stackView.addArrangedSubview(itemView)
        }
    }
    
    override open func becomeFirstResponder() -> Bool {
        let items = stackView.arrangedSubviews
            .map({$0 as! VerificationTextFieldItem})
        return (items.filter({($0.textField.text ?? "").isEmpty}).first ?? items.last)!.becomeFirstResponder()
    }

    override open func resignFirstResponder() -> Bool {
        stackView.arrangedSubviews.forEach({$0.resignFirstResponder()})
        return true
    }

    override open func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupView()
    }
    
}

extension VerificationTextFieldView: UITextFieldDelegate, VerificationTextFieldDelegate {
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        
        if string.isEmpty {
            textField.text = ""
            _ = delegate?.verificationTextFieldView(self, valueDidChange: self.code)
            return true
        }

        if !textField.hasText {
            let index = textField.tag
            let item = stackView.arrangedSubviews[index] as! VerificationTextFieldItem
            item.textField.text = string
            sendActions(for: .valueChanged)
            if (delegate?.verificationTextFieldView(self, valueDidChange: self.code) ?? false) {
                textField.resignFirstResponder()
            }

            if (index + 1 ) < length {
                _ = stackView.arrangedSubviews[index + 1].becomeFirstResponder()
            }
        }

        return false
    }

    func deleteBackward(sender: VerificationTextField, previousValue: String?) {
        for i in 1..<length {
            let itemView = stackView.arrangedSubviews[i] as! VerificationTextFieldItem

            guard itemView.textField.isFirstResponder, (previousValue?.isEmpty ?? true) else {
                continue
            }

            let prevItem = stackView.arrangedSubviews[i-1] as! VerificationTextFieldItem
            if itemView.textField.text?.isEmpty ?? true {
                prevItem.textField.text = ""
                _ = prevItem.becomeFirstResponder()
            }
        }
        _ = delegate?.verificationTextFieldView(self, valueDidChange: self.code)
        sendActions(for: .valueChanged)
    }
}
