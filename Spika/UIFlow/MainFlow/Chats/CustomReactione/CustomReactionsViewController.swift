//
//  CustomReactionsViewController.swift
//  Spika
//
//  Created by Nikola Barbarić on 08.08.2023..
//

import Foundation
import UIKit

class CustomReactionsViewController: BaseViewController {
    private let mainView = CustomReactionsView()
    var viewModel: CustomReactionsViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView(mainView)
    }
}
