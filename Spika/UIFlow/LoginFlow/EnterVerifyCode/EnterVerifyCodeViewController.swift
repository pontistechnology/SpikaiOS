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
        setupBindings()
    }
    
    func setupBindings() {
        enterVerifyCodeView.nextButton.tap().sink { _ in
            print("VerifyCode Next tap: ")
//            self.enterVerifyCodeView.showApiStatusImageView(true, isFinished: false)
            self.viewModel.verifyCode(code: self.enterVerifyCodeView.verificationTextFieldView.code)
        }.store(in: &subscriptions)
        
        enterVerifyCodeView.resendCodeButton.tap().sink { _ in
            self.viewModel.resendCode()
        }.store(in: &subscriptions)
        
        viewModel.resendSubject.sink { [weak self] resended in
            if resended {
                self?.enterVerifyCodeView.setupTimer()
            }
        }.store(in: &subscriptions)
        
        sink(networkRequestState: viewModel.networkRequestState)
        
        
        
        
    }
    
}
