//
//  UIImage+Extensions.swift
//  Spika
//
//  Created by Nikola Barbarić on 09.03.2022..
//

import Foundation
import UIKit

extension UIImage {
    func resizeImageToFitPixels(size: CGSize) -> UIImage? {
        let pixelsSize = CGSize(width: size.width / UIScreen.main.scale,
                                height: size.height / UIScreen.main.scale)
        UIGraphicsBeginImageContextWithOptions(pixelsSize, false, 0.0)
        self.draw(in: CGRect(origin: CGPoint.zero, size: pixelsSize))
        guard let resizedImage = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return resizedImage
    }
}
