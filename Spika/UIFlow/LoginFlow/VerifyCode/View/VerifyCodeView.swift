//
//  VerifyCodeView.swift
//  Spika
//
//  Created by Marko on 28.10.2021..
//

import UIKit

class VerifyCodeView: UIView, BaseView {
    
    let logoImage = LogoImageView()
    let titleLabel = UILabel()
    let verificationTextFieldView = VerificationTextFieldView(length: 6)
    let nextButton = MainButton()
    let timeLabel = UILabel()
    let resendCodeButton = ActionButton()
    var timer: Timer?
    var timeCounter: Int = 120
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupTimer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        addSubview(logoImage)
        addSubview(titleLabel)
        addSubview(verificationTextFieldView)
        addSubview(nextButton)
        addSubview(timeLabel)
        addSubview(resendCodeButton)
    }
    
    func styleSubviews() {
        titleLabel.font = UIFont(name: "Montserrat-Medium", size: 14)
        titleLabel.text = "We sent you verification code on +385998851598"
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        
        verificationTextFieldView.delegate = self
        
        nextButton.setTitle("Next", for: .normal)
        nextButton.setEnabled(false)
        
        resendCodeButton.setTitle("Resend code", for: .normal)
        
        
        timeLabel.text = "02:00"
        timeLabel.font = UIFont(name: "Montserrat-Medium", size: 14)
    }
    
    func positionSubviews() {
        logoImage.anchor(top: topAnchor, padding: UIEdgeInsets(top: 40, left: 0, bottom: 24, right: 0), size: CGSize(width: 72, height: 72))
        logoImage.centerX(inView: self)
        
        titleLabel.anchor(top: logoImage.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 24, left: 70, bottom: 50, right: 70))
        
        timeLabel.anchor(top: titleLabel.bottomAnchor, leading: leadingAnchor, padding: UIEdgeInsets(top: 50, left: 30, bottom: 16, right: 30))
        timeLabel.constrainWidth(100)
        
        resendCodeButton.anchor(trailing: trailingAnchor, padding: UIEdgeInsets(top: 50, left: 30, bottom: 16, right: 30))
        resendCodeButton.constrainWidth(100)
        resendCodeButton.centerY(inView: timeLabel)
        
        verificationTextFieldView.anchor(top: timeLabel.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 16, left: 30, bottom: 14, right: 30))
        verificationTextFieldView.constrainHeight(44)
        
        nextButton.anchor(top: verificationTextFieldView.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 14, left: 30, bottom: 0, right: 30))
        nextButton.constrainHeight(50)
    }
    
    func setupTimer() {
        timeCounter = 120
        timer?.invalidate()
        timer = Timer(timeInterval: 1.0, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    @objc func fireTimer(timer: Timer) {
        timeCounter -= 1
        let mins: String = timeCounter > 59 ? "01:" : "00"
        var seconds: String = timeCounter > 59 ? "\(timeCounter - 60)" : "\(timeCounter)"
        if (timeCounter > 59 && timeCounter - 60 < 10) { seconds = "0\(seconds)" }
        if timeCounter == 0 {
            timer.invalidate()
            timeLabel.text = "00:00"
        } else {
            timeLabel.text = "\(mins)\(seconds)"
        }
    }
    
}

extension VerifyCodeView: VerificationTextFieldViewDelegate {
    func verificationTextFieldView(_ verificationTextFieldView: VerificationTextFieldView, valueDidChange code: String) -> Bool {
        
        nextButton.setEnabled(code.count == verificationTextFieldView.length)
        return true
    }
    
    
}
