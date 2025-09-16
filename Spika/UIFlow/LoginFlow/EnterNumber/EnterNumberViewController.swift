//
//  EnterNumberViewController.swift
//  Spika
//
//  Created by Marko on 27.10.2021..
//

import UIKit

class EnterNumberViewController: BaseViewController {
    
    private let enterNumberView = EnterNumberView()
    var viewModel: EnterNumberViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.setGradientBackground(colors: UIColor._backgroundGradientColors)
        setupView(enterNumberView)
        setupBindings()
    }
    
    func setupBindings() {
        let deviceId: String
        if let oldData = viewModel.checkIfUserWasLogged() {
            deviceId = oldData.deviceId
            enterNumberView.setCountryCode(code: oldData.phoneNumber.countryCode)
            enterNumberView.setRestOfNumber(oldData.phoneNumber.restOfNumber)
            enterNumberView.enterNumberTextField.isUserInteractionEnabled = false
            enterNumberView.changeTitle() // TODO: - text check
        } else {
            deviceId = UUID().uuidString
            enterNumberView.enterNumberTextField.countryNumberLabel.tap().sink { [weak self] _ in
                guard let self else { return }
                self.viewModel.presentCountryPicker(delegate: self)
            }.store(in: &subscriptions)
        }
        
        enterNumberView.nextButton.tap().sink { [weak self] _ in
            guard let phoneNumber = self?.enterNumberView.getTelephoneNumber() else { return }
            self?.viewModel.authenticateWithNumber(telephoneNumber: phoneNumber, deviceId: deviceId)
        }.store(in: &subscriptions)
        
        sink(networkRequestState: viewModel.networkRequestState)
    }
}

extension EnterNumberViewController: CountryPickerViewDelegate {
    func countryPickerViewDelegate(_ countryPickerViewController: CountryPickerViewController, didSelectCountry country: Country) {
        enterNumberView.setCountryCode(code: country.phoneCode)
    }
}
