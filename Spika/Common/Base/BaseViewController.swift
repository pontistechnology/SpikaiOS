//
//  BaseViewController.swift
//  Spika
//
//  Created by Marko on 06.10.2021..
//

import UIKit
import Combine

class BaseViewController: UIViewController {
    
    var subscriptions = Set<AnyCancellable>()
    let activityIndicator = UIActivityIndicatorView()
    let activityLabel = CustomLabel(text: "", textSize: 30, textColor: .white, fontName: .MontserratMedium, alignment: .center)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barStyle = .default
        navigationController?.setNavigationBarHidden(false, animated: animated)
        UITextField.appearance().tintColor = UIColor.systemTeal
        navigationItem.backButtonTitle = " "
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func setupView(_ view: UIView) {
        self.view.backgroundColor = .whiteAndDarkBackground
        self.view.addSubview(view)
        view.fillSuperviewSafeAreaLayoutGuide()
        hideKeyboardWhenTappedAround()
    }
    
    private func showLoading() {
        view.addSubview(activityLabel)
        view.addSubview(activityIndicator)
        activityIndicator.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        activityLabel.centerYToSuperview(offset: 30)
        activityLabel.centerXToSuperview()
        
        activityLabel.layer.cornerRadius = 7
        activityLabel.layer.masksToBounds = true
        
        activityLabel.backgroundColor = .textTertiaryAndDarkBackground2
        activityIndicator.backgroundColor = .darkGray.withAlphaComponent(0.5)
        activityIndicator.startAnimating()
    }
    
    private func hideLoading() {
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
    }
    
    func sink(networkRequestState publisher: CurrentValueSubject<RequestState, Never>) {
        publisher.sink { state in
            switch state {
            case .finished:
                self.hideLoading()
            case .started:
                self.showLoading()
            case .progress(let progress):
                self.activityLabel.text = String(format: "%.2f", progress * 100) + " %"
            }
        }.store(in: &subscriptions)
    }
}

extension BaseViewController {
    func hideKeyboardWhenTappedAround() {
            let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
            tap.cancelsTouchesInView = false
            view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
