//
//  AppereanceSettingsViewModel.swift
//  Spika
//
//  Created by Nikola Barbarić on 07.02.2023..
//

import Foundation
import UIKit

class AppereanceSettingsViewModel: BaseSettingsViewModel, ObservableObject {
    func changeAppereanceMode(to theme: SpikaTheme) {
        repository.saveSelectedTheme(theme.rawValue)
    }
    
    func returnToHomeScreen() {
        getAppCoordinator()?.presentHomeScreen(startSyncAndSSE: true)
    }
    
    func savedThemeRawValue() -> String {
        repository.getSelectedTheme()
    }
}
