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
                    viewModel.changeAppereanceMode(to: theme)
                    viewModel.returnToHomeScreen()
                }.padding(.horizontal, 16)
            }
            Button(action: {
                viewModel.returnToHomeScreen()
            }, label: {
                Text(verbatim: .getStringFor(.cancel))
                    .foregroundStyle(Color(UIColor.textSecondary))
            })
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .modifier(SpikaBackgroundGradient())
    }
}
