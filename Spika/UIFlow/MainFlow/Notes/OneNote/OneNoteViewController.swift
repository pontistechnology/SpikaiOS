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
        mainView.configureView(note: viewModel.noteStatePublisher.value.note)
        setupBindings()
    }
    
    func setupNavigationItems() {
        let modeButton = UIBarButtonItem(title: viewModel.noteStatePublisher.value.buttonTitle,
                                         style: .plain,
                                         target: self,
                                         action: #selector(barButtonTap))
        navigationItem.rightBarButtonItems = [modeButton]
    }
    
    func setupBindings() {
        viewModel.noteStatePublisher.sink { [weak self] state in
            self?.mainView.changeMode(isEditing: state.isEditable)
            self?.setupNavigationItems()
        }.store(in: &subscriptions)
        
        mainView.keyboardAccessoryView.publisher.sink { _ in
            
        } receiveValue: { [weak self] distance in
            self?.mainView.moveInputFromBottom(for: distance)
        }.store(in: &subscriptions)
        
        sink(networkRequestState: viewModel.networkRequestState)
    }
    
    @objc func barButtonTap() {
        switch viewModel.noteStatePublisher.value {
        case .creatingNew(roomId: let roomId):
            guard let title = mainView.titleTextView.text,
                  let content = mainView.contentTextView.text,
                  !title.isEmpty, !content.isEmpty
            else { return }
            viewModel.createNote(title: title, content: content, roomId: roomId)
        case .viewing(note: let note):
            viewModel.noteStatePublisher.send(.editing(note: note))
        case .editing(note: let note):
            guard let newTitle = mainView.titleTextView.text,
                  let newContent = mainView.contentTextView.text,
                  newTitle != note.title || newContent != note.content
            else {
                viewModel.noteStatePublisher.send(.viewing(note: note))
                return
            }
            viewModel.editNote(title: newTitle, content: newContent, id: note.id)
        }
    }
}
