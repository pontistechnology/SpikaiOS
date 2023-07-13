//
//  TermsAndConditionViewModel.swift
//  Spika
//
//  Created by Nikola Barbarić on 13.07.2023..
//

import Foundation
import UIKit

class TermsAndConditionViewModel: BaseViewModel {
    
    func openTermsAndConditions() {
        repository.openTermsAndConditions()
    }
    
    func presentEnterNumberScreen() {
        getAppCoordinator()?.presentEnterNumberScreen()
    }
}
