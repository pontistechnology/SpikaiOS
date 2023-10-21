//
//  AppereanceSettingsViewModel.swift
//  Spika
//
//  Created by Nikola Barbarić on 07.02.2023..
//

import Foundation
import UIKit

class AppereanceSettingsViewModel: BaseSettingsViewModel {
    func getThemeFor(index: Int) -> SpikaTheme {
        let cases = SpikaTheme.allCases
        guard index < cases.count else { return .nika }
        return cases[index]
    }
    
    func changeAppereanceMode(to theme: SpikaTheme) {
        repository.saveSelectedTheme(theme.rawValue)
        getAppCoordinator()?.changeAppereance(to: .dark)
    }
}
