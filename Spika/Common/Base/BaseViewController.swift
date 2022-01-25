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
}
