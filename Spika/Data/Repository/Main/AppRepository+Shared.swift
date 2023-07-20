//
//  AppRepository+Shared.swift
//  Spika
//
//  Created by Nikola Barbarić on 13.07.2023..
//

import Foundation
import UIKit

extension AppRepository {
    func openTermsAndConditions() {
        guard let link = URL(string: "https://clover.studio/projects/spika/spika-messenger-terms-and-coditions/") else { return }
        
        if UIApplication.shared.canOpenURL(link) {
            UIApplication.shared.open(link)
        }
    }
}
