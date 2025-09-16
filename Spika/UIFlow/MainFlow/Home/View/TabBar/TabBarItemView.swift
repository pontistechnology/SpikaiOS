//
//  TabBarItemView.swift
//  Spika
//
//  Created by Vedran Vugrin on 09.11.2022..
//

import UIKit
import Combine

class TabBarItemView: UIView, BaseView {
    
    let tabSelectedPublisher = PassthroughSubject<TabBarItem,Never>()
    var subscriptions = Set<AnyCancellable>()
    
    lazy var button: UIButton = {
        let button = UIButton()
        return button
    } ()
    
    lazy var highlightsView: UIView = {
        let highlightsView = UIView()
        highlightsView.layer.cornerRadius = 10
        highlightsView.layer.masksToBounds = true
        return highlightsView
    } ()
    
    lazy var counterLabel: CustomLabel = {
        let label = CustomLabel(text: "", textSize: 10, textColor: .textPrimary, fontName: .RobotoFlexSemiBold, alignment: .center)
        label.backgroundColor = .primaryColor
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        label.hide()
        return label
    } ()
    
    let tab: TabBarItem
    
    init(tabBarItem: TabBarItem) {
        self.tab = tabBarItem
        super.init(frame: CGRectZero)
        self.button.setImage(tabBarItem.imageNormal, for: .normal)
        
        self.addSubviews()
        self.styleSubviews()
        self.positionSubviews()
        
        self.button
            .publisher(for: .touchUpInside)
            .sink { [weak self] _ in
                guard let tab = self?.tab else { return }
                self?.tabSelectedPublisher.send(tab)
            }.store(in: &self.subscriptions)
    }
    
    func updateIsSelected(isSelected: Bool) {
        let options: UIView.AnimationOptions = isSelected ? [.curveEaseIn] : [.curveEaseOut]
        
        DispatchQueue.main.async { [weak self] in
            UIView.animate(withDuration: 0.4,
                           delay: 0.0,
                           usingSpringWithDamping: 1.0,
                           initialSpringVelocity: 0.5,
                           options: options,
                           animations: { [weak self] in
                self?.highlightsView.backgroundColor = isSelected ? .fourthAdditionalColor : .clear
                self?.button.setImage(isSelected ? self?.tab.imageSelected : self?.tab.imageNormal, for: .normal)
                (self?.superview as? UIStackView)?.layoutIfNeeded()
            }, completion: nil)            
        }
    }
    
    func updateCountLabel(_ text: String?) {
        counterLabel.text = text
        counterLabel.isHidden = text == nil
    }
    
    required init?(coder: NSCoder) {
        self.tab = .chat(withChatId: nil)
        super.init(coder: coder)
    }
    
    func addSubviews() {
        addSubview(highlightsView)
        addSubview(button)
        addSubview(counterLabel)
    }
    
    func styleSubviews() {}
    
    func positionSubviews() {
        highlightsView.centerInSuperview()
        button.fillSuperview()
        
        highlightsView.anchor(size: CGSize(width: 46, height: 46))
        
        counterLabel.centerXToSuperview(offset: 18)
        counterLabel.centerYToSuperview(offset: -14)
        counterLabel.anchor(size: CGSize(width: 20, height: 20))
    }
    
}
