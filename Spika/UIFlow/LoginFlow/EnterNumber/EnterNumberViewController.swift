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
        setupView(enterNumberView)
        setupBindings()
        print(UIDevice.current.identifierForVendor!.uuidString)
    }
    
    func setupBindings() {
        enterNumberView.enterNumberTextField.countryNumberLabel.tap().sink { _ in
            self.viewModel.presentCountryPicker(delegate: self)
        }.store(in: &subscriptions)
        
        enterNumberView.nextButton.tap().sink { _ in
            guard let fullNumber = self.enterNumberView.getFullNumber() else { return }
            guard let countryCode = self.enterNumberView.getCountryCode(removePlus: true) else { return }
            self.viewModel.authenticateWithNumber(
                number: fullNumber,
                deviceId: UUID().uuidString,
                countryCode: countryCode)
        }.store(in: &subscriptions)
    }
}

extension EnterNumberViewController: CountryPickerViewDelegate {
    func countryPickerViewDelegate(_ countryPickerViewController: CountryPickerViewController, didSelectCountry country: Country) {
        enterNumberView.setCountryCode(code: country.phoneCode)
    }
    
    
}
