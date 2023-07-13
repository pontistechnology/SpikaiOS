//
//  TermsAndConditionViewController.swift
//  Spika
//
//  Created by Nikola Barbarić on 13.07.2023..
//

import Foundation
import UIKit

class TermsAndConditionViewController: BaseViewController {
    var viewModel: TermsAndConditionViewModel!
    private let mainView = TermsAndConditionView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView(mainView)
        setupBindings()
    }
    
    func setupBindings() {
        mainView.termsAndConditionsLabel.tap().sink { [weak self] _ in
            self?.viewModel.openTermsAndConditions()
        }.store(in: &subscriptions)
        
        mainView.agreeLabel.tap().sink { [weak self] _ in
            self?.viewModel.presentEnterNumberScreen()
        }.store(in: &subscriptions)
    }
}
