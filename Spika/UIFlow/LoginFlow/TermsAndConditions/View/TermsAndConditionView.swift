//
//  TermsAndConditionView.swift
//  Spika
//
//  Created by Nikola Barbarić on 13.07.2023..
//

import Foundation
import UIKit

class TermsAndConditionView: UIView {
    
    private let logo = UIImageView(image: UIImage(safeImage: .logo))
    private let welcomeLabel = CustomLabel(text: .getStringFor(.welcomeToSpika), textSize: 24, textColor: ._textPrimary, fontName: .MontserratSemiBold, alignment: .center)
    private let tapLabel = CustomLabel(text: .getStringFor(.tapAgreeAndContinueToAcceptThe), textSize: 16, textColor: ._textPrimary, alignment: .center)
    let termsAndConditionsLabel = CustomLabel(text: .getStringFor(.termsAndConditions), textSize: 16, textColor: .primaryColor, alignment: .center)
    let agreeLabel = CustomLabel(text: .getStringFor(.agreeAndContinue), textSize: 18, textColor: ._textPrimary, fontName: .MontserratSemiBold, alignment: .center)
    
    init() {
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // TODO: - refactor agree button shape
}

extension TermsAndConditionView: BaseView {
    func addSubviews() {
        addSubview(logo)
        addSubview(welcomeLabel)
        addSubview(tapLabel)
        addSubview(termsAndConditionsLabel)
        addSubview(agreeLabel)
    }
    
    func styleSubviews() {
        let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.thick.rawValue]
        let underlineAttributedString = NSAttributedString(string: .getStringFor(.termsAndConditions).lowercased(), attributes: underlineAttribute)
        termsAndConditionsLabel.attributedText = underlineAttributedString
    }
    
    func positionSubviews() {
        logo.centerXToSuperview()
        logo.constrainWidth(200)
        logo.constrainHeight(200)
        logo.anchor(top: topAnchor, padding: UIEdgeInsets(top: 80, left: 0, bottom: 0, right: 0))
        
        welcomeLabel.centerXToSuperview()
        welcomeLabel.anchor(top: logo.bottomAnchor, padding: UIEdgeInsets(top: 30, left: 0, bottom: 0, right: 0))
        
        tapLabel.centerXToSuperview()
        tapLabel.anchor(top: welcomeLabel.bottomAnchor, padding: UIEdgeInsets(top: 60, left: 0, bottom: 0, right: 0))
        
        termsAndConditionsLabel.centerXToSuperview()
        termsAndConditionsLabel.anchor(top: tapLabel.bottomAnchor, padding: UIEdgeInsets(top: 6, left: 0, bottom: 0, right: 0))
        
        agreeLabel.centerXToSuperview()
        agreeLabel.anchor(top: termsAndConditionsLabel.bottomAnchor, padding: UIEdgeInsets(top: 60, left: 0, bottom: 0, right: 0))
    }
}
