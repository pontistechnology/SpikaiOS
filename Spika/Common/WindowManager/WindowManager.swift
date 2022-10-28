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
    private var indicatorWindow: UIWindow?
    
    private init() {
        setupIndicatorWindow()
    }
}

// MARK: - Indicator Window
private extension WindowManager {
    func setupIndicatorWindow() {
        guard let windowScene = UIApplication.shared.connectedScenes.filter({ $0.activationState == .foregroundActive }).first as? UIWindowScene
        else { return }
        indicatorWindow = UIWindow(windowScene: windowScene)
        let x = windowScene.screen.bounds.width - 15
        indicatorWindow?.frame = CGRect(x: x, y: 60, width: 8, height: 8)
        indicatorWindow?.rootViewController = ConnectionIndicatorViewController()
        indicatorWindow?.isHidden = false
    }
}

extension WindowManager {
    func changeIndicatorColor(to color: UIColor) {
        (indicatorWindow?.rootViewController as? ConnectionIndicatorViewController)?.changeIndicatorColor(to: color)
    }
}
