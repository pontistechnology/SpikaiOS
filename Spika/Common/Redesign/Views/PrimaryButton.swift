//
//  MainButtton.swift
//  Spika
//
//  Created by Nikola Barbarić on 10.11.2023..
//

import SwiftUI

struct PrimaryButton: View {
    enum Usage {
        case withCheckmark
        case withRightArrow
        case onlyTitle
        case withToggle(Binding<Bool>)
        
        var imageResource: ImageResource? {
            return switch self {
            case .withCheckmark: .rDcheckmark
            case .withRightArrow: .rDrightArrow
            case .onlyTitle: nil
            case .withToggle: nil
            }
        }
    }
    
    private let leftImageResource: ImageResource?
    private let text: String
    private var corners: UIRectCorner?
    private let backgroundColor: UIColor
    private let action: () -> ()
    private let usage: Usage
    
    init(imageResource: ImageResource? = nil, text: String, corners: UIRectCorner? = nil, backgroundColor: UIColor = .primaryColor, usage: Usage = .onlyTitle, action: @escaping ()->()) {
        self.leftImageResource = imageResource
        self.text = text
        self.corners = corners
        self.backgroundColor = backgroundColor
        self.action = action
        self.usage = usage
    }
    
    var body: some View {
        Button(action: action,
               label: {
            HStack(spacing: 0) {
                if let leftImageResource {
                    Spacer().frame(width: 16)
                    Image(leftImageResource)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(Color(uiColor: .textPrimary))
                }
                Spacer().frame(width: 11)
                Text(text)
                    .foregroundStyle(Color(uiColor: .textPrimary))
                    .font(.customFont(.RobotoFlexSemiBold, size: 14))
                Spacer()
                
                if let rightImageResource = usage.imageResource {
                    Image(rightImageResource)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .padding(.trailing, 16)
                        .foregroundStyle(Color(uiColor: UIColor.textPrimary))
                    // TODO: -
                }
                
                if case .withToggle(let isOn) = usage {
                    Toggle("", isOn: isOn)
                        .padding(.trailing, 16)
                }

            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Color(uiColor: backgroundColor))
            .modifier(RoundedCorners(corners: corners, radius: 15))
        })
    }
}
