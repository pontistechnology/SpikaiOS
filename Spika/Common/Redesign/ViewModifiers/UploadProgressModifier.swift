//
//  UploadProgressModifier.swift
//  Spika
//
//  Created by Nikola Barbarić on 14.11.2023..
//

import SwiftUI

struct UploadProgressModifier: ViewModifier {
    let isShowing: Bool
    func body(content: Content) -> some View {
        ZStack {
            content
            if isShowing {
                Color(.additionalColor.withAlphaComponent(0.5))
                
                // TODO: - ask for design and make custom progress circle
                ProgressView()
                    .progressViewStyle(.circular)                
            }
        }
    }
}
