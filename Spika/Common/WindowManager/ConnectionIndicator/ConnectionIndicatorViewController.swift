//
//  ConnectionIndicatorViewController.swift
//  Spika
//
//  Created by Nikola Barbarić on 28.10.2022..
//

import UIKit

class ConnectionIndicatorViewController: UIViewController {
    private let indicatorView = ConnectionIndicatorView()
}

extension ConnectionIndicatorViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
}

extension ConnectionIndicatorViewController {
    func setupView() {
        view.addSubview(indicatorView)
        indicatorView.anchor(top: view.topAnchor,
                             leading: view.leadingAnchor,
                             padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
    }
}

extension ConnectionIndicatorViewController {
    func changeIndicatorColor(to color: UIColor) {
        indicatorView.changeColor(to: color)
    }
}
