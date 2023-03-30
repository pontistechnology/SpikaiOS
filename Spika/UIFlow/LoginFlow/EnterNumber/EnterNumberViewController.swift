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
    }
    
    func setupBindings() {
        enterNumberView.enterNumberTextField.countryNumberLabel.tap().sink { [weak self] _ in
            guard let self else { return }
            self.viewModel.presentCountryPicker(delegate: self)
        }.store(in: &subscriptions)
        
        enterNumberView.nextButton.tap().sink { [weak self] _ in
            guard let self,
                  let fullNumber = self.enterNumberView.getFullNumber(),
                  let uuid = UIDevice.current.identifierForVendor?.uuidString
            else { return }
            
            self.viewModel.authenticateWithNumber(
                number: fullNumber,
                deviceId: uuid)
        }.store(in: &subscriptions)
        
        sink(networkRequestState: viewModel.networkRequestState)
    }
}

extension EnterNumberViewController: CountryPickerViewDelegate {
    func countryPickerViewDelegate(_ countryPickerViewController: CountryPickerViewController, didSelectCountry country: Country) {
        enterNumberView.setCountryCode(code: country.phoneCode)
    }
}
