//
//  PopUpManager.swift
//  Spika
//
//  Created by Nikola Barbarić on 24.02.2022..
//

import Foundation
import UIKit
import CoreMedia

class PopUpManager {
    
    static let shared = PopUpManager()
    
    var alertWindow: UIWindow?
    var completions: [() -> ()]?
    
    private init() {
    
    }
    
    func presentAlert(_ choice : StaticInfoAlert) {
        let alertViewController = AlertViewController(choice)
        setupAlertWindow(with: alertViewController)
    }
    
    func presentAlert(errorMessage: String) {
        let alertViewController = AlertViewController(message: errorMessage)
        setupAlertWindow(with: alertViewController)
    }
    
    func presentAlert(with titleAndMessage: (title: String, message: String)? = nil, orientation: NSLayoutConstraint.Axis, closures: [(String, () -> ())]) {
        
        completions = closures.map{ $0.1 }
        
        let alertViewController = AlertViewController(withTitleAndMessage: titleAndMessage, orientation: orientation, 
                                                      closureNames: closures.map{ $0.0 })
        setupAlertWindow(with: alertViewController)
    }
    
    private func setupAlertWindow(with viewController: AlertViewController) {
        
        guard let windowScene = UIApplication.shared.connectedScenes.filter({ $0.activationState == .foregroundActive }).first as? UIWindowScene
        else { return }
        
        viewController.delegate = self
        
        let alertWindow = UIWindow(windowScene: windowScene)
        alertWindow.rootViewController = viewController
        alertWindow.isHidden = false
        alertWindow.overrideUserInterfaceStyle = .light
        self.alertWindow = alertWindow
    }
    
    private func dismissAlertWindow() {
        self.alertWindow = nil
    }
}

extension PopUpManager: AlertViewControllerDelegate {
    func alertViewController(_ alertViewController: AlertViewController, needDismiss value: Bool) {
        dismissAlertWindow()
    }
    
    func alertViewController(_ alertViewController: AlertViewController, indexInStackView value: Int) {
        guard let closures = completions else { return }
        closures[value]()
        dismissAlertWindow()
    }
}
