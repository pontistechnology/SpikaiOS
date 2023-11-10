//
//  RoundedCorners.swift
//  Spika
//
//  Created by Nikola Barbarić on 10.11.2023..
//

import SwiftUI

struct RoundedCorners: ViewModifier {
    let corners: UIRectCorner?
    let radius: CGFloat
    
    func body(content: Content) -> some View {
        if let corners {
            content.clipShape(RoundedCorner(radius: radius, corners: corners))
        } else {
            content
        }
    }
    
    struct RoundedCorner: Shape {
        
        var radius: CGFloat
        var corners: UIRectCorner
        
        func path(in rect: CGRect) -> Path {
            let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            return Path(path.cgPath)
        }
    }
}
