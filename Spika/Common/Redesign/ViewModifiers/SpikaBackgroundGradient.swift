//
//  SpikaBackgroundGradient.swift
//  Spika
//
//  Created by Nikola Barbarić on 13.11.2023..
//

import SwiftUI

struct SpikaBackgroundGradient: ViewModifier {
    var withImage = false
    func body(content: Content) -> some View {
        content
            .background(.linearGradient(colors: UIColor._backgroundGradientColors.map({ Color(uiColor: $0)
            }), startPoint: UnitPoint(x: 0.2, y: 0.1),
                                        endPoint: UnitPoint(x: 1.2, y: 1.3)))
    }
}
