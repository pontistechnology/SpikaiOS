//
//  AlertViewController.swift
//  Spika
//
//  Created by Nikola Barbarić on 24.02.2022..
//

import UIKit

protocol AlertViewControllerDelegate: AnyObject {
    func alertViewController(_ alertViewController: AlertViewController, needDismiss value: Bool)
    func alertViewController(_ alertViewController: AlertViewController, indexInStackView value: Int)
}

class AlertViewController: BaseViewController {
    
    weak var delegate: AlertViewControllerDelegate?
    let alertView: AlertView
    
    init(withTitleAndMessage: (String, String)?, orientation: NSLayoutConstraint.Axis, closureNames: [String]) {
        alertView = AlertView(titleAndMessage: withTitleAndMessage, orientation: orientation, buttonTexts: closureNames)
        super.init(nibName: nil, bundle: nil)
    }
    
    init(message: String) {
        alertView = AlertView(message: message)
        super.init(nibName: nil, bundle: nil)
    }
    
    init(_ choice: StaticInfoAlert) {
        alertView = AlertView(choice)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        alertView.delegate = self
    }
    
    func setupView() {
        view.addSubview(alertView)
        alertView.fillSuperview()
    }
    
}

extension AlertViewController: AlertViewDelegate {
    func alertView(_ alertView: AlertView, needDismiss value: Bool) {
        delegate?.alertViewController(self, needDismiss: true)
    }
    
    func alertView(_ alertView: AlertView, indexOfPressedVerticalButton value: Int) {
        delegate?.alertViewController(self, indexInStackView: value)
    }
}
