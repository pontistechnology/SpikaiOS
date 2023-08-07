//
//  OneNoteViewController.swift
//  Spika
//
//  Created by Nikola Barbarić on 07.08.2023..
//

import Foundation
import UIKit

class OneNoteViewController: BaseViewController {
    private let mainView = OneNoteView()
    var viewModel: OneNoteViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView(mainView)
        setupBindings()
    }
    
    func setupNavigationItems(toEditMode: Bool) {
        let modeButton = UIBarButtonItem(title: toEditMode ? .getStringFor(.save) : .getStringFor(.edit),
                                         style: .plain,
                                         target: self,
                                         action: #selector(changeMode))
        navigationItem.rightBarButtonItems = [modeButton]
    }
    
    func setupBindings() {
        viewModel.isEditingModePublisher.sink { [weak self] isEditingMode in
            self?.setupNavigationItems(toEditMode: isEditingMode)
        }.store(in: &subscriptions)
    }
    
    @objc func changeMode() {
        viewModel.isEditingModePublisher.value.toggle()
    }
}
