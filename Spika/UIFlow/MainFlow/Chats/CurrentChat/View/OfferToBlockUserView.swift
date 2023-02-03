//
//  OfferToBlockUserView.swift
//  Spika
//
//  Created by Vedran Vugrin on 13.01.2023..
//

import UIKit

final class OfferToBlockUserView: UserBlockedView {
    
    let okButton = MainButton()
    
    override func styleSubviews() {
        super.styleSubviews()
        blockUnblockButton.setTitle(.getStringFor(.block), for: .normal)
        label.text = .getStringFor(.newContact)
        
        okButton.backgroundColor = .appWhite
        okButton.setTitleColor(.black, for: .normal)
        okButton.setTitle(.getStringFor(.ok), for: .normal)
    }
    
    override func addSubviews() {
        super.addSubviews()
        self.horizontalStackView.addArrangedSubview(self.okButton)
    }
    
}
