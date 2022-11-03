//
//  StackItemView.swift
//  Spika
//
//  Created by Marko on 21.10.2021..
//

import UIKit
import Combine

protocol StackItemViewDelegate: AnyObject {
    func handleTap(_ view: StackItemView)
}

class StackItemView: UIView, BaseView {
    
    var titleLbl = UILabel()
    var imageView = UIImageView()
    var highlightsView = UIView()
    
    var indicationPublisher: AnyPublisher<String,Never>? {
        didSet {
            self.indicationPublisher?
                .sink(receiveValue: { string in
                    self.counterLabel.text = string
                    self.counterLabel.isHidden = string.isEmpty
                }).store(in: &subscriptions)
        }
    }
    
    var subscriptions = Set<AnyCancellable>()
    
//    var counterView: UIView?
    lazy var counterLabel: CustomLabel = {
        let label = CustomLabel(text: "", textSize: 10, textColor: .white, fontName: .MontserratSemiBold, alignment: .center)
        label.backgroundColor = .appRed
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        label.isHidden = true
        return label
    } ()
    
    private let higlightBGColor = UIColor.appBlueLight
    private let selectedImageColor = UIColor.primaryColor
    private let defualtImageColor = UIColor.navigation
    
    static var newInstance: StackItemView {
        return StackItemView()
    }
    
    weak var delegate: StackItemViewDelegate?
    
    init() {
        super.init(frame: .zero)
        setupView()
        self.addTapGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var isSelected: Bool = false {
        willSet {
            self.updateUI(isSelected: newValue)
        }
    }
    
    var item: Any? {
        didSet {
            self.configure(self.item)
        }
    }
    
    private func configure(_ item: Any?) {
        guard let model = item as? TabBarItem else { return }
        self.titleLbl.text = model.title
        self.imageView.image = UIImage(named: model.image)?.withRenderingMode(.alwaysTemplate)
        self.isSelected = model.isSelected
    }
    
    private func updateUI(isSelected: Bool) {
        guard var model = item as? TabBarItem else { return }
        model.isSelected = isSelected
        let options: UIView.AnimationOptions = isSelected ? [.curveEaseIn] : [.curveEaseOut]
        
        UIView.animate(withDuration: 0.4,
                       delay: 0.0,
                       usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 0.5,
                       options: options,
                       animations: {
                        self.titleLbl.text = isSelected ? "" : ""
                        let color = isSelected ? self.higlightBGColor : UIColor.clear
                        self.highlightsView.backgroundColor = color
                        self.titleLbl.textColor = isSelected ? .white : self.higlightBGColor
                        self.imageView.tintColor = isSelected ? self.selectedImageColor : self.defualtImageColor
                        (self.superview as? UIStackView)?.layoutIfNeeded()
        }, completion: nil)
    }
    
    func addSubviews() {
        addSubview(highlightsView)
        addSubview(imageView)
        addSubview(titleLbl)
        addSubview(counterLabel)
    }
    
    func styleSubviews() {
        titleLbl.textAlignment = .center
        
        highlightsView.layer.cornerRadius = 23
        highlightsView.layer.masksToBounds = true
    }
    
    func positionSubviews() {
        highlightsView.centerInSuperview()
        highlightsView.anchor(size: CGSize(width: 46, height: 46))
        highlightsView.anchor(paddingTop: 3, paddingBottom: 3)
        
        imageView.anchor(left: leftAnchor, paddingLeft: 5, width: 24, height: 24)
        imageView.centerY(inView: self)
        
        titleLbl.anchor(left: imageView.rightAnchor, right: self.rightAnchor, paddingLeft: 5, paddingRight: 0)
        titleLbl.centerY(inView: self)
        
        counterLabel.centerXToSuperview(offset: 18)
        counterLabel.centerYToSuperview(offset: -18)
        counterLabel.anchor(size: CGSize(width: 20, height: 20))
    }
    
}

extension StackItemView {
    
    func addTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
        self.addGestureRecognizer(tapGesture)
    }
    
    @objc
    func handleGesture(_ sender: UITapGestureRecognizer) {
        self.delegate?.handleTap(self)
    }
    
}

