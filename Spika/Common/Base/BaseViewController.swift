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
    let circularProgressBar = CircularProgressBar(spinnerWidth: 24)
    
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
    
    private func showLoading(progress: CGFloat?) {
        if let _ = circularProgressBar.superview {
            print("jes")
        } else {
            view.addSubview(circularProgressBar)
            circularProgressBar.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        }
        
        if let progress = progress {
            circularProgressBar.setProgress(to: progress)
        } else {
            circularProgressBar.startSpinning()
        }
    }
    
    private func hideLoading() {
        circularProgressBar.removeFromSuperview()
    }
    
    func sink(networkRequestState publisher: CurrentValueSubject<RequestState, Never>) {
        publisher.sink { state in
            switch state {
            case .finished:
                self.hideLoading()
            case .started(let progress):
                self.showLoading(progress: progress)
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
