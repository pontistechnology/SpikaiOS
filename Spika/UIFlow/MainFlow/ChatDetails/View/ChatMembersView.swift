//
//  ChatMembersView.swift
//  Spika
//
//  Created by Vedran Vugrin on 11.11.2022..
//

import UIKit

final class ChatMembersView: UIView, BaseView {
    
    let contactsEditable: Bool
    
    lazy var mainStackView: UIStackView = {
       let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill
        return stackView
    } ()
    
    lazy var horizontalTitleStackView: UIStackView = {
       let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fill
        return stackView
    } ()
    
    let titleLabel = CustomLabel(text: "Members", textSize: 28,
                                 textColor: .textPrimaryAndWhite,
                                 fontName: .MontserratSemiBold)
    
    lazy var addContactButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(safeImage: .plus), for: .normal)
        return button
    } ()
    
    lazy var showMoreButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(NSLocalizedString("Show more", comment: "Show more"), for: .normal)
        return button
    } ()
    
    let tableView = ContactsTableView()
    
    init(contactsEditable: Bool) {
        self.contactsEditable = contactsEditable
        super.init(frame: CGRectZero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        self.addSubview(self.mainStackView)
        
        self.mainStackView.addArrangedSubview(self.horizontalTitleStackView)
        self.horizontalTitleStackView.addArrangedSubview(self.titleLabel)
        
        if self.contactsEditable {
            self.horizontalTitleStackView.addArrangedSubview(self.addContactButton)
        }
        
        self.mainStackView.addArrangedSubview(self.tableView)
        self.mainStackView.addArrangedSubview(self.showMoreButton)
    }
    
    func styleSubviews() {}
    
    func positionSubviews() {
        self.mainStackView.fillSuperview()
    }
    
}
