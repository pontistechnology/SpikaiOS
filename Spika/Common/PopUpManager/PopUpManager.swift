//
//  PopUpManager.swift
//  Spika
//
//  Created by Nikola Barbarić on 24.02.2022..
//

import Foundation
import UIKit

class PopUpManager {
    
    static let shared = PopUpManager()
    
    var alertWindow: UIWindow?
    var firstButtonCompletion: (() -> ())?
    var secondButtonCompletion: (() -> ())?
    
    func presentAlert(withTitle title: String,
                      message: String,
                      rightButtonText: String,
                      completion1: @escaping () -> (),
                      leftButtonText: String,
                      completion2: @escaping () -> ()) {
        
        firstButtonCompletion  = completion1
        secondButtonCompletion = completion2
        
        let alertViewController = AlertViewController(title: title, message: message, rightButtonText: rightButtonText, leftButtonText: leftButtonText)
        setupAlertWindow(with: alertViewController)
    }
    
    func presentAlert(withTitle title: String,
                      message: String,
                      firstButtonText: String,
                      completion1: @escaping () -> ()) {
        
        let alertViewController = AlertViewController(title: title, message: message, firstButtonText: firstButtonText)
        firstButtonCompletion  = completion1
        setupAlertWindow(with: alertViewController)
    }
    
    func presentAlert(errorMessage: String) {
        let alertViewController = AlertViewController(message: errorMessage)
        setupAlertWindow(with: alertViewController)
    }
    
    func setupAlertWindow(with viewController: AlertViewController) {
        
        guard let windowScene = UIApplication.shared.connectedScenes.filter({ $0.activationState == .foregroundActive }).first as? UIWindowScene
        else { return }
        
        viewController.delegate = self
        
        let alertWindow = UIWindow(windowScene: windowScene)
        alertWindow.rootViewController = viewController
        alertWindow.isHidden = false
        alertWindow.overrideUserInterfaceStyle = .light
        self.alertWindow = alertWindow
    }
    
    func dismissAlertWindow() {
        self.alertWindow = nil
    }
}

extension PopUpManager: AlertViewControllerDelegate {
    func alertViewController(_ alertViewController: AlertViewController, didPressFirstButton value: Bool) {
        firstButtonCompletion?()
        dismissAlertWindow()
    }
    
    func alertViewController(_ alertViewController: AlertViewController, didPressSecondButton value: Bool) {
        secondButtonCompletion?()
        dismissAlertWindow()
    }
    
    func alertViewController(_ alertViewController: AlertViewController, needDismiss value: Bool) {
        dismissAlertWindow()
    }
}
