//
//  AllNotesViewController.swift
//  Spika
//
//  Created by Nikola Barbarić on 11.02.2022..
//

import Foundation
import UIKit

class AllNotesViewController: BaseViewController {
    
    private let notesView = AllNotesView()
    var viewModel: AllNotesViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.setGradientBackground(colors: UIColor._backgroundGradientColors)
        setupView(notesView)
        setupBindings()
        setupNavigationItems()
        navigationItem.title = .getStringFor(.notes)
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.textPrimary]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.getAllNotes()
    }
    
    func setupNavigationItems() {
        let modeButton = UIBarButtonItem(image: .init(resource: .plus).withTintColor(.textPrimary, renderingMode: .alwaysOriginal), style: .plain, target: self, action: #selector(createNewNote))
        navigationItem.rightBarButtonItems = [modeButton]
    }
    
    @objc func createNewNote() {
        viewModel.presentOneNoteScreen(noteState: .creatingNew(roomId: viewModel.roomId))
    }
    
    func setupBindings() {
        notesView.notesTableView.delegate = self
        notesView.notesTableView.dataSource = self
        
        viewModel.notesPublisher.sink { _ in
            
        } receiveValue: { [weak self] notes in
            self?.notesView.notesTableView.reloadData()
        }.store(in: &subscriptions)
    }
}

extension AllNotesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NoteTableViewCell.reuseIdentifier, for: indexPath)
        let note = viewModel.notesPublisher.value[indexPath.row]
        let timeText: String
        //        let timeText: String
        //        if let edited = note.modifiedAt, note.createdAt != edited {
        //            timeText = "Edited: " + "\(edited.convert(to: .notesTimeFormat))"
        //        } else {
        //            timeText = "Created: " + "\(note.createdAt.convert(to: .notesTimeFormat))"
        //        }
                
        (cell as? NoteTableViewCell)?.configureCell(title: note.title)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.notesPublisher.value.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        56
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.presentOneNoteScreen(noteState: .viewing(note: viewModel.notesPublisher.value[indexPath.row]))
    }
}

extension AllNotesViewController {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let detailsAction = UIContextualAction(style: .destructive, title: nil) { [weak self] (action, view, completionHandler) in
            guard let note = self?.viewModel.notesPublisher.value[indexPath.row] else { return }
            self?.viewModel.askToDelete(note: note)
            completionHandler(true)
        }
        detailsAction.image = UIImage(resource: .slideDelete)
        return UISwipeActionsConfiguration(actions: [detailsAction])
    }
}
