//
//  ConnectionIndicatorView.swift
//  Spika
//
//  Created by Nikola Barbarić on 28.10.2022..
//

import UIKit
import Combine

class ConnectionIndicatorView: UIView {
    private var subs = Set<AnyCancellable>()
    
    init() {
        super.init(frame: .zero)
        layer.cornerRadius = 4
        constrainWidth(8)
        constrainHeight(8)
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ConnectionIndicatorView {
    func setupBindings() {
        WindowManager.shared.indicatorColorPublisher.sink { [weak self] color in
            self?.backgroundColor = color
        }.store(in: &subs)
    }
}
