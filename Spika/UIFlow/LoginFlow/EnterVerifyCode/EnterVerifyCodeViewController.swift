//
//  EnterVerifyCodeViewController.swift
//  Spika
//
//  Created by Marko on 28.10.2021..
//

import UIKit

class EnterVerifyCodeViewController: BaseViewController {
    
    private let enterVerifyCodeView = EnterVerifyCodeView()
    var viewModel: EnterVerifyCodeViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView(enterVerifyCodeView)
        setupUI()
        setupBindings()
    }
    
    func setupUI() {
        enterVerifyCodeView.titleLabel.text = "We sent you 6 digit verification code on \(viewModel.phoneNumber)."
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        enterVerifyCodeView.timer?.invalidate()
        enterVerifyCodeView.timer = nil
    }
    
    func setupBindings() {
        enterVerifyCodeView.nextButton.tap().sink { [weak self] _ in
            guard let self = self else { return }
            self.viewModel.verifyCode(code: self.enterVerifyCodeView.otpTextField.text!)
        }.store(in: &subscriptions)
        
        enterVerifyCodeView.resendCodeButton.tap().sink { [weak self] _ in
            guard let self = self else { return }
            self.viewModel.resendCode()
        }.store(in: &subscriptions)
        
        viewModel.resendSubject.sink { [weak self] resended in
            guard let self = self else { return }
            if resended {
                self.enterVerifyCodeView.setupTimer()
            }
        }.store(in: &subscriptions)
        
        sink(networkRequestState: viewModel.networkRequestState)
    }
}
