//
//  AppereanceSettingsViewModel.swift
//  Spika
//
//  Created by Nikola Barbarić on 07.02.2023..
//

import Foundation
import UIKit

class AppereanceSettingsViewModel: BaseSettingsViewModel {
    func changeAppereanceMode(to mode: UIUserInterfaceStyle) {
        getAppCoordinator()?.changeAppereance(to: mode)
    }
}
