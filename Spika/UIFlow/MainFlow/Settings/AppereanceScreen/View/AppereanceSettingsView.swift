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
            ForEach(SpikaTheme.allCases, id: \.rawValue) { theme in
                let isSelected = viewModel.savedThemeRawValue() == theme.rawValue
                PrimaryButton(text: theme.title, corners: theme.corners,
                              usage: isSelected ? .withCheckmark : .onlyTitle) {
                    viewModel.changeAppereanceMode(to: SpikaTheme.allCases.filter({ $0 != theme }).randomElement() ?? theme)
                    viewModel.returnToHomeScreen()
                }
            }
            PrimaryButton(text: .getStringFor(.cancel), corners: .bottomCorners, backgroundColor: .secondaryColor) {
                viewModel.returnToHomeScreen()
            }
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .modifier(SpikaBackgroundGradient())
    }
}
