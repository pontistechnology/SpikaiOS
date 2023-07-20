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
        enterVerifyCodeView.titleLabel.text = .getStringFor(.weSentYou6DigitOn) + " \(viewModel.phoneNumber.getFullNumber())."
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // TODO: - move timer from view
        enterVerifyCodeView.timer?.invalidate()
        enterVerifyCodeView.timer = nil
    }
    
    func setupBindings() {
        enterVerifyCodeView.nextButton.tap().sink { [weak self] _ in
            guard let self,
                  let verifyCode = self.enterVerifyCodeView.otpTextField.text
            else { return }
            self.viewModel.verifyCode(code: verifyCode)
        }.store(in: &subscriptions)
        
        enterVerifyCodeView.resendCodeButton.tap().sink { [weak self] _ in
            guard let self else { return }
            self.viewModel.resendCode()
        }.store(in: &subscriptions)
        
        enterVerifyCodeView
            .otpCodePublisher
            .sink(receiveValue: { [weak self] otpCode in
                self?.viewModel.verifyCode(code: otpCode)
            }).store(in: &subscriptions)
        
        viewModel.resendSubject.sink { [weak self] resended in
            guard let self else { return }
            if resended {
                self.enterVerifyCodeView.setupTimer()
            }
        }.store(in: &subscriptions)
        
        sink(networkRequestState: viewModel.networkRequestState)
    }
}
