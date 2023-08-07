//
//  OTPCodeTextField.swift
//  Spika
//
//  Created by Vedran Vugrin on 18.10.2022..
//

import UIKit
import Combine

final class OTPCodeTextField: UITextField {
    
    private let otpLength: Int
    private var subs = Set<AnyCancellable>()
    let isEntryGood = PassthroughSubject<Bool, Never>()
    
    init(otpLength: Int) {
        self.otpLength = otpLength
        super.init(frame: CGRectZero)
        setupView()
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        self.otpLength = 0
        super.init(coder: coder)
    }
}

extension OTPCodeTextField: BaseView {
    func addSubviews() {}
    
    func styleSubviews() {
        keyboardType = .numberPad
        textContentType = .oneTimeCode
        backgroundColor = .secondaryBackground
        textAlignment = .center
        autocapitalizationType = .none
        layer.borderColor = UIColor.borderColor.cgColor
        layer.borderWidth = 1
        layer.masksToBounds = false
        layer.cornerRadius = 10
        font = .customFont(name: .MontserratMedium, size: 26)
        textColor = .textPrimary
    }
    
    func positionSubviews() {}
}

extension OTPCodeTextField {
    func setupBindings() {
        self.publisher(for: .editingChanged)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
            guard let self, var inputText = self.text,
                  inputText.isNumber
            else {
                self?.text = ""
                return
            }
            
            inputText = String(inputText.prefix(self.otpLength))
            self.text = inputText
            let entryGood = inputText.count == self.otpLength
            self.layer.borderColor = entryGood ? UIColor.borderColor.cgColor : UIColor.appRed.cgColor
            self.isEntryGood.send(entryGood)
        }.store(in: &subs)
    }
}

// MARK: - Changing dark/light mode for cgColors

extension OTPCodeTextField {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        layer.borderColor = UIColor.borderColor.cgColor
        self.setNeedsDisplay()
    }
}


