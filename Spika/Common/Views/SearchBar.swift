//
//  SearchBar.swift
//  Spika
//
//  Created by Marko on 24.10.2021..
//

import UIKit
import Combine

protocol SearchBarDelegate: AnyObject {
    func searchBar(_ searchBar: SearchBar, valueDidChange value: String?)
    func searchBar(_ searchBar: SearchBar, didPressCancel value: Bool)
}

class SearchBar: UIView, BaseView {
    
    let searchView = UIView()
    let searchImage = UIImageView(image: UIImage(named: "search"))
    let searchTextField = UITextField()
    let deleteImage = UIImageView(image: UIImage(named: "delete"))
    let cancelButton = UIButton()
    
    weak var delegate: SearchBarDelegate?
    var placeholder: String = ""
    private let shouldShowCancel: Bool
    private var subscriptions = Set<AnyCancellable>()
    
    init(placeholder: String = "", shouldShowCancel: Bool = false) {
        self.shouldShowCancel = shouldShowCancel
        self.placeholder = placeholder
        super.init(frame: .zero)
        setupView()
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        if self.shouldShowCancel {
            addSubview(cancelButton)
        }
        addSubview(searchView)
        searchView.addSubview(searchImage)
        searchView.addSubview(searchTextField)
        searchView.addSubview(deleteImage)
    }
    
    func styleSubviews() {
        backgroundColor = .clear
        
        deleteImage.isHidden = true
        
        searchTextField.textColor = .textPrimaryAndWhite
        searchTextField.customFont(name: .MontserratMedium, size: 14)
        searchTextField.attributedPlaceholder = NSAttributedString(string: placeholder,
                                                                   attributes: [NSAttributedString.Key.foregroundColor: UIColor.textTertiary])
        
        searchView.backgroundColor = .chatBackgroundAndDarkBackground2
        searchView.layer.cornerRadius = 10
        searchView.clipsToBounds = true
        
        cancelButton.setTitle(Constants.Strings.cancel, for: .normal)
        cancelButton.setTitleColor(.primaryColor, for: .normal)
        cancelButton.titleLabel?.customFont(name: .MontserratMedium, size: 14)
    }
    
    func positionSubviews() {
        self.constrainHeight(50)
        
        if self.shouldShowCancel {
            cancelButton.anchor(trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0), size: CGSize(width: 50, height: 20))
            cancelButton.centerY(inView: self)
            
            searchView.anchor(top: self.topAnchor, leading: self.leadingAnchor, bottom: self.bottomAnchor, trailing: cancelButton.leadingAnchor, padding: UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0))
        } else {
            searchView.anchor(top: self.topAnchor, leading: self.leadingAnchor, bottom: self.bottomAnchor, trailing: self.trailingAnchor, padding: UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0))
        }
        
        searchImage.anchor(leading: searchView.leadingAnchor, padding: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15), size: CGSize(width: 18, height: 18))
        searchImage.centerY(inView: searchView)
        
        deleteImage.anchor(trailing: searchView.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 12), size: CGSize(width: 16, height: 16))
        deleteImage.centerY(inView: searchView)
        
        searchTextField.anchor(top: searchView.topAnchor, leading: searchImage.trailingAnchor, bottom: searchView.bottomAnchor, trailing: deleteImage.leadingAnchor, padding: UIEdgeInsets(top: 4, left: 15, bottom: 4, right: 30))
        
    }
    
    func setupBindings() {
        deleteImage.tap().sink { [weak self] _ in
            self?.clearTextField()
        }.store(in: &subscriptions)
        
        cancelButton.tap().sink { [weak self] _ in
            guard let self = self else { return }
            self.delegate?.searchBar(self, didPressCancel: true)
        }.store(in: &subscriptions)
        
        searchTextField.addTarget(self, action: #selector(SearchBar.textFieldDidChange(_:)), for: .editingChanged)
    }

    @objc func textFieldDidChange(_ textField: UITextField) {
        if let value = textField.text {
            if value.isEmpty {
                self.clearTextField()
            } else {
                self.deleteImage.isHidden = false
                delegate?.searchBar(self, valueDidChange: value)
            }
        } else {
            self.searchTextField.endEditing(true)
            delegate?.searchBar(self, valueDidChange: nil)
        }
    }
    
    func clearTextField() {
        self.searchTextField.text = ""
        self.deleteImage.isHidden = true
        delegate?.searchBar(self, valueDidChange: "")
    }
}

