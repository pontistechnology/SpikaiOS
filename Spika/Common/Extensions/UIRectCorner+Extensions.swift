//
//  UIRectCorner+Extensions.swift
//  Spika
//
//  Created by Nikola Barbarić on 10.11.2023..
//

import UIKit

extension UIRectCorner {
    static let topCorners: UIRectCorner = [.topLeft, .topRight]
    static let bottomCorners: UIRectCorner =  [.bottomLeft, .bottomRight]
    static let leftCorners: UIRectCorner = [.bottomLeft, .topLeft]
    static let rightCorners: UIRectCorner = [.bottomRight, .topRight]
}

extension CACornerMask {
    static let allButBottomRight: CACornerMask = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner]
    static let allButBottomLeft: CACornerMask = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
}
