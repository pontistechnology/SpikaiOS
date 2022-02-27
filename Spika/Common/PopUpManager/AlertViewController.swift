//
//  AlertViewController.swift
//  Spika
//
//  Created by Nikola Barbarić on 24.02.2022..
//

import UIKit

protocol AlertViewControllerDelegate: AnyObject {
    func alertViewController(_ alertViewController: AlertViewController, didPressFirstButton value: Bool)
    func alertViewController(_ alertViewController: AlertViewController, didPressSecondButton value: Bool)
    func alertViewController(_ alertViewController: AlertViewController, needDismiss value: Bool)
}

class AlertViewController: BaseViewController {
    
    weak var delegate: AlertViewControllerDelegate?
    var alertView: AlertView?
    var startPosition: CGFloat?
    var endPosition: CGFloat?
    
    init(title: String, message: String, rightButtonText: String, leftButtonText: String) {
        super.init(nibName: nil, bundle: nil)
        alertView = AlertView(title: title, message: message, rightButtonText: rightButtonText, leftButtonText: leftButtonText)
    }
    
    init(title: String, message: String, firstButtonText: String) {
        super.init(nibName: nil, bundle: nil)
        alertView = AlertView(title: title, message: message, firstButtonText: firstButtonText)
    }
    
    init(message: String) {
        super.init(nibName: nil, bundle: nil)
        alertView = AlertView(message: message)
        addGestures()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
//        view = alertView
        addTargets()
//        view.backgroundColor = .clear
    }
    
    func setupView() {
        guard let alertView = alertView else {
            return
        }
        view.addSubview(alertView)
        alertView.fillSuperview()
    }
    
    func addTargets() {
        alertView?.firstButton.addTarget(self, action: #selector(firstButtonActionHandler), for: .touchUpInside)
        alertView?.secondButton.addTarget(self, action: #selector(secondButtonActionHandler), for: .touchUpInside)
    }
    
    func addGestures() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(draggedView(_:)))
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(alertViewTapped))
        alertView?.containerView.addGestureRecognizer(panGesture)
        alertView?.addGestureRecognizer(tapGesture)
    }
    
    @objc func firstButtonActionHandler() {
        delegate?.alertViewController(self, didPressFirstButton: true)
    }
    
    @objc func secondButtonActionHandler() {
        delegate?.alertViewController(self, didPressSecondButton: true)
    }
    
    @objc func alertViewTapped() {
        UIView.animate(withDuration: 1, delay: 0) {
            self.alertView?.containerView.transform = CGAffineTransform(translationX: 0, y: -200)
            self.alertView?.containerView.alpha = 0
            self.alertView?.backgroundColor = .clear
        } completion: { status in
            self.delegate?.alertViewController(self, needDismiss: true)
        }
    }
    
    @objc func draggedView(_ sender: UIPanGestureRecognizer) {
        guard let alertView = alertView else {
            return
        }
        
        if sender.state == .began {
            startPosition = alertView.containerView.center.y
        } else if sender.state == .ended {
            endPosition = alertView.containerView.center.y
            
            guard let startPosition = startPosition,
                  let endPosition = endPosition
            else {
                return
            }
            
            if endPosition-startPosition < -30.0 {
                UIView.animate(withDuration: 1, delay: 0) {
                    self.alertView?.containerView.transform = CGAffineTransform(translationX: 0, y: -200)
                    self.alertView?.containerView.alpha = 0
                    self.alertView?.backgroundColor = .clear
                } completion: { status in
                    self.delegate?.alertViewController(self, needDismiss: true)
                }
            } else {
                UIView.animate(withDuration: 1, delay: 0) {
                    self.alertView?.containerView.center.y = 60 + (self.alertView?.containerView.frame.height ?? 100) / 2
                }
            }
        }
        
        let translation = sender.translation(in: self.view)
        alertView.containerView.center = CGPoint(x: alertView.containerView.center.x,
                                                 y: alertView.containerView.center.y  + translation.y)
        sender.setTranslation(CGPoint.zero, in: self.view)
    
    }
    
}

