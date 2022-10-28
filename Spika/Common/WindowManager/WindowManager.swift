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
        indicatorWindow?.frame = CGRect(x: 30, y: 30, width: 130, height: 130)
        indicatorWindow?.backgroundColor = .green
        indicatorWindow?.rootViewController = ConnectionIndicatorViewController()
        indicatorWindow?.isHidden = false
    }
}

extension WindowManager {
    func showGreen() {
        print("hi")
    }
}
