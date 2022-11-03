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
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        title = " "
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
//        let name = String(describing: self.self)
//        print("\(name) deinit")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barStyle = .default
        navigationController?.setNavigationBarHidden(false, animated: animated)
        UITextField.appearance().tintColor = UIColor.systemTeal
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
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if let _ = self.circularProgressBar.superview {
                print("jes")
            } else {
                self.view.addSubview(self.circularProgressBar)
                self.circularProgressBar.anchor(top: self.view.topAnchor, leading: self.view.leadingAnchor, bottom: self.view.bottomAnchor, trailing: self.view.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
            }
            
            if let progress = progress {
                self.circularProgressBar.setProgress(to: progress)
            } else {
                self.circularProgressBar.startSpinning()
            }
        }
    }
    
    private func hideLoading() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.circularProgressBar.removeFromSuperview()
        }
    }
    
    func sink(networkRequestState publisher: CurrentValueSubject<RequestState, Never>) {
        publisher.sink { [weak self] state in
            guard let self = self else { return }
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
