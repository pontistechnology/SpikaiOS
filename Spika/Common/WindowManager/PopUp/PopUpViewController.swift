//
//  ErrorAlertViewController.swift
//  Spika
//
//  Created by Nikola Barbarić on 04.11.2022..
//

import UIKit
import Combine
// TODO: refactor for errors
class PopUpViewController: BaseViewController {
    let popUpView: UIView
    let publisher: PassthroughSubject<PopUpPublisherType, Never>
    
    init(_ type: PopUpType, publisher: PassthroughSubject<PopUpPublisherType, Never>) {
        self.publisher = publisher
        switch type {
        case .errorMessage(let message):
            popUpView = ErrorMessageView(message: message)
            publisher.send(.dismiss(after: 3))
        }
        super.init()

        view.addSubview(popUpView)
        popUpView.centerInSuperview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
