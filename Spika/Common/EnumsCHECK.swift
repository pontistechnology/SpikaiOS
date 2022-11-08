//
//  Enums+Extensions.swift
//  Spika
//
//  Created by Nikola Barbarić on 04.11.2022..
//

import UIKit


enum OneSecPopUpType {
    case copy
    case forward
    case favorite
    
    var image: UIImage {
        switch self {
        case .copy, .favorite, .forward:
            return UIImage(safeImage: .error) // TODO: - add assets
        }
    }
    
    var description: String {
        switch self {
        case .copy:
            return "Copied"
        case .forward:
            return "Forwarded"
        case .favorite:
            return "Added to favorite"
        }
    }
}

enum PopUpType {
    case errorMessage(_ message: String)
    case alertView(title: String, message: String, buttons: [AlertViewButton])
    case oneSec(OneSecPopUpType)
    
    var isBlockingUI: Bool {
        switch self {
        case .oneSec, .alertView:
            return true
        case .errorMessage:
            return false
        }
    }
    
    func frame(for scene: UIWindowScene) -> CGRect {
        isBlockingUI
        ? CGRect(x: 0, y: 0, width: scene.screen.bounds.width, height: scene.screen.bounds.height)
        : CGRect(x: 0, y: 0, width: scene.screen.bounds.width, height: 150)
    }
}

enum AlertViewButton {
    case regular(title: String)
    case destructive(title: String)
    
    var color: UIColor {
        switch self {
        case .regular:
            return .primaryColor
        case .destructive:
            return .appRed
        }
    }
    
    var title: String {
        switch self {
        case .regular(let title):
            return title
        case .destructive(let title):
            return title
        }
    }
}
