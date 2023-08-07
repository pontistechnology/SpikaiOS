//
//  NotesViewController.swift
//  Spika
//
//  Created by Nikola Barbarić on 11.02.2022..
//

import Foundation
import UIKit

class NotesViewController: BaseViewController {
    
    private let notesView = NotesView()
    var viewModel: NotesViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView(notesView)
        setupBindings()
        viewModel.getAllNotes()
        navigationItem.title = .getStringFor(.notes)
    }
    
    func setupBindings() {
        notesView.notesTableView.delegate = self
        notesView.notesTableView.dataSource = self
        
        viewModel.notesPublisher.sink { _ in
            
        } receiveValue: { [weak self] notes in
            print("ima notes: ", notes.count)
            print("notes: ", notes)
            self?.notesView.notesTableView.reloadData()
        }.store(in: &subscriptions)
    }
}

extension NotesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NoteTableViewCell.reuseIdentifier, for: indexPath)
        (cell as? NoteTableViewCell)?.configureCell(title: viewModel.notesPublisher.value[indexPath.row].title)
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.notesPublisher.value.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        58
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
