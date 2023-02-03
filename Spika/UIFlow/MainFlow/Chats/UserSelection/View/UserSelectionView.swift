//
//  UserSelectionView.swift
//  Spika
//
//  Created by Vedran Vugrin on 16.11.2022..
//

import Foundation
import UIKit

class UserSelectionView: UIView, BaseView {
    
    let mainVerticalStackView = CustomStackView(spacing: 20)
    
    lazy var topVerticakStackView: UIStackView = {
        let stack = CustomStackView()
        stack.layoutMargins = UIEdgeInsets(top: 0, left: 22, bottom: 0, right: 22)
        stack.isLayoutMarginsRelativeArrangement = true
        return stack
    } ()
    
    let topHorizontalStackView = CustomStackView(axis:.horizontal)
    
    let cancelLabel = CustomLabel(text: .getStringFor(.cancel), textSize: 18, textColor: .primaryColor, fontName: .MontserratSemiBold)
    let doneLabel = CustomLabel(text: .getStringFor(.done), textSize: 18, textColor: .primaryColor, fontName: .MontserratSemiBold)
    let titleLabel = CustomLabel(text: .getStringFor(.selectUsers), textSize: 28, textColor: .textPrimary)
    let numberSelectedUsersLabel = CustomLabel(text: "0/100 " + .getStringFor(.selected), textSize: 11, textColor: .textPrimary)
    let searchBar = SearchBar(placeholder: .getStringFor(.searchForContact), shouldShowCancel: false)
    let contactsTableView = ContactsTableView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .appWhite
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        self.addSubview(mainVerticalStackView)
        
        mainVerticalStackView.addArrangedSubview(self.topVerticakStackView)
        
        topVerticakStackView.addArrangedSubview(self.topHorizontalStackView)
        topHorizontalStackView.addArrangedSubview(self.cancelLabel)
        topHorizontalStackView.addArrangedSubview(self.doneLabel)
        
        topVerticakStackView.addArrangedSubview(self.titleLabel)
        topVerticakStackView.addArrangedSubview(self.numberSelectedUsersLabel)
        topVerticakStackView.addArrangedSubview(self.searchBar)
        
        mainVerticalStackView.addArrangedSubview(self.contactsTableView)
    }
    
    func styleSubviews() {}
    
    func positionSubviews() {
        self.mainVerticalStackView.constraint(with: UIEdgeInsets(top: 12, left: 0, bottom: -24, right: 0))
    }

}
