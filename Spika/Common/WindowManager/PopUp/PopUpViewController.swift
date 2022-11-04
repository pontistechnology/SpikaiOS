//
//  ErrorAlertViewController.swift
//  Spika
//
//  Created by Nikola Barbarić on 04.11.2022..
//

import UIKit
import Combine

class PopUpViewController: BaseViewController {
    let popUpView: UIView
    let publisher: PassthroughSubject<PopUpPublisherType, Never>
    
    init(_ type: PopUpType, publisher: PassthroughSubject<PopUpPublisherType, Never>) {
        self.publisher = publisher
        switch type {
        case .oneSec(let type):
            popUpView = OneSecPopUpView(type: type)
            publisher.send(.dismiss(after: 1))
        case .errorMessage(let message):
            popUpView = ErrorMessageView(message: message)
            publisher.send(.dismiss(after: 3))
        case .alertView(title: let title, message: let message, buttons: let buttons):
            popUpView = AlertView(title: title, message: message, buttons: buttons)
        }
        super.init(nibName: nil, bundle: nil)
        
        view.addSubview(popUpView)
        popUpView.centerInSuperview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PopUpViewController {
    
}
