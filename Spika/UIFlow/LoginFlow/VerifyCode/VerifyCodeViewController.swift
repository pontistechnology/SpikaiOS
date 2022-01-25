//
//  VerifyCodeViewController.swift
//  Spika
//
//  Created by Marko on 28.10.2021..
//

import UIKit

class VerifyCodeViewController: BaseViewController {
    
    private let verifyCodeView = VerifyCodeView()
    var viewModel: VerifyCodeViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView(verifyCodeView)
        setupBindings()
    }
    
    func setupBindings() {
        verifyCodeView.nextButton.tap().sink { _ in
            self.viewModel.verifyCode(code: self.verifyCodeView.verificationTextFieldView.code)
        }.store(in: &subscriptions)
        
        verifyCodeView.resendCodeButton.tap().sink { _ in
            self.viewModel.resendCode()
        }.store(in: &subscriptions)
        
        viewModel.resendSubject.sink { [weak self] resended in
            if resended {
                self?.verifyCodeView.setupTimer()
            }
        }.store(in: &subscriptions)
        
    }
    
}
