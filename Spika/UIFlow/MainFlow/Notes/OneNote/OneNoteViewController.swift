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
        mainView.configureView(note: viewModel.note)
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
            self?.mainView.changeMode(isEditing: isEditingMode)
        }.store(in: &subscriptions)
        
        mainView.keyboardAccessoryView.publisher.sink { _ in
            
        } receiveValue: { [weak self] distance in
            self?.mainView.moveInputFromBottom(for: distance)
        }.store(in: &subscriptions)
        
        sink(networkRequestState: viewModel.networkRequestState)
    }
    
    @objc func changeMode() {
        let newTitle = mainView.titleTextView.text ?? viewModel.note.title
        let newContent = mainView.contentTextView.text ?? viewModel.note.content
        
        if viewModel.note.content != newContent
            || viewModel.note.title != newTitle
        {
            viewModel.updateNote(title: newTitle, content: newContent)
        }
        viewModel.isEditingModePublisher.value.toggle()
    }
}
