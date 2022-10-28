//
//  WindowManager.swift
//  Spika
//
//  Created by Nikola Barbarić on 28.10.2022..
//

import Foundation
import UIKit

class WindowManager {

    static let shared = WindowManager()
    var indicatorWindow: UIWindow?
    
    private init() {
        setupIndicatorWindow()
    }
}

extension WindowManager {
    func setupIndicatorWindow() {
        guard let windowScene = UIApplication.shared.connectedScenes.filter({ $0.activationState == .foregroundActive }).first as? UIWindowScene
        else { return }
        indicatorWindow = UIWindow(windowScene: windowScene)
        let x = windowScene.screen.bounds.width / 2 - 5
        indicatorWindow?.frame = CGRect(x: x, y: 60, width: 10, height: 10)
        indicatorWindow?.backgroundColor = .green // TODO: - delete
        indicatorWindow?.rootViewController = ConnectionIndicatorViewController()
        indicatorWindow?.isHidden = false
    }
}

extension WindowManager {
    func showGreen() {
        print("hi")
    }
}
