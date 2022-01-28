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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barStyle = .default
        navigationController?.setNavigationBarHidden(true, animated: animated)
        UITextField.appearance().tintColor = UIColor.systemTeal
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func setupView(_ view: UIView) {
        self.view.backgroundColor = .whiteAndDarkBackground
        self.view.addSubview(view)
        view.fillSuperviewSafeAreaLayoutGuide()
    }
    
    func showLoading() {
        for view in view.subviews {
            view.isHidden = true
        }
        
        let test = UIImageView()
        test.image = UIImage(named: "logoAndCheck")
        view.addSubview(test)
        view.centerXToSuperview()
        view.centerYToSuperview(offset: -100)
        view.constrainHeight(170)
        view.constrainWidth(170)
//        apiStatusImageView.image = isFinished ? UIImage(named: "logoAndCheck") : UIImage(named: "logo")
//        apiStatusImageView.isHidden = !present
//        errorMessageLabel.isHidden = present
    }
}
