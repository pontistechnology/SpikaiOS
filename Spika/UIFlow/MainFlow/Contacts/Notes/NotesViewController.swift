//
//  NotesViewController.swift
//  Spika
//
//  Created by Nikola Barbarić on 11.02.2022..
//

import Foundation

class NotesViewController: BaseViewController {
    
    private let notesView = NotesView()
    var viewModel: NotesViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView(notesView)
        setupBindings()
        navigationItem.title = "Notes"
    }
    
    func setupBindings() {
        
    }
}
