//
//  AppereanceSettings2View.swift
//  Spika
//
//  Created by Nikola Barbarić on 12.11.2023..
//

import SwiftUI

struct AppereanceSettingsView: View {
    @StateObject var viewModel: AppereanceSettingsViewModel
    
    var body: some View {
        VStack {
            Text("Appearance")
                .font(.customFont(.RobotoFlexSemiBold, size: 32))
                .foregroundStyle(Color.fromUIColor(.textPrimary))
                .frame(maxWidth: .infinity, alignment: .center)
            
            Spacer()
            
            ForEach(SpikaTheme.allCases, id: \.rawValue) { theme in
                let isSelected = viewModel.savedThemeRawValue() == theme.rawValue
                PrimaryButton(text: theme.title, corners: theme.corners,
                              usage: isSelected ? .withCheckmark : .onlyTitle) {
                    viewModel.changeAppereanceMode(to: theme)
                    viewModel.returnToHomeScreen()
                }
            }
            Button {
                viewModel.returnToHomeScreen()
            } label: {
                Text("Cancel")
                    .foregroundStyle(Color(uiColor: .textPrimary))
                    .font(.customFont(.RobotoFlexSemiBold, size: 14))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Color.fromUIColor(.secondaryColor))
            .modifier(RoundedCorners(corners: .bottomCorners, radius: 15))
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .modifier(SpikaBackgroundGradient())
    }
}
