//
//  MainButtton.swift
//  Spika
//
//  Created by Nikola Barbarić on 10.11.2023..
//

import SwiftUI

struct PrimaryButton: View {
    private let imageResource: ImageResource
    private let text: String
    private var corners: UIRectCorner?
    private let backgroundColor: UIColor
    private let action: () -> ()
    
    init(imageResource: ImageResource, text: String, corners: UIRectCorner? = nil, backgroundColor: UIColor = .primaryColor, action: @escaping ()->()) {
        self.imageResource = imageResource
        self.text = text
        self.corners = corners
        self.backgroundColor = backgroundColor
        self.action = action
    }
    
    var body: some View {
        Button(action: action,
               label: {
            HStack(spacing: 0) {
                Image(imageResource)
                    .padding(.leading, 16)
                    .padding(.trailing, 12)
                    .foregroundStyle(Color(uiColor: .tertiaryColor))
                Text(text)
                    .foregroundStyle(Color(uiColor: .textPrimary))
                    .font(Font(UIFont.customFont(name: .MontserratSemiBold, size: 14)))
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Color(uiColor: backgroundColor))
            .modifier(RoundedCorners(corners: corners, radius: 15))
        })
    }
}

#Preview {
    PrimaryButton(imageResource: .privacyEye, text: "Privacy", corners: .bottomCorners) {
        
    }
}
