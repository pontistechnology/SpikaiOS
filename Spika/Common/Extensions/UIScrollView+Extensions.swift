//
//  UIScrollView+Extensions.swift
//  Spika
//
//  Created by Nikola Barbarić on 18.05.2023..
//

import UIKit

extension UIScrollView {
    func distanceFromBottom() -> CGFloat {
        let contentOffset = contentOffset
        let contentHeight = contentSize.height
        let frameHeight = frame.height
        return contentHeight - contentOffset.y - frameHeight
    }
}
