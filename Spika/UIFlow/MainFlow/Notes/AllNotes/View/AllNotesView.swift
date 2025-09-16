
//
//  NotesView.swift
//  Spika
//
//  Created by Nikola Barbarić on 11.02.2022..
//

import Foundation
import UIKit

class AllNotesView: UIView, BaseView {
    
    let notesTableView = UITableView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        notesTableView.register(NoteTableViewCell.self, forCellReuseIdentifier: NoteTableViewCell.reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        addSubview(notesTableView)
    }
    
    func styleSubviews() {
        notesTableView.separatorStyle = .none
        backgroundColor = .clear
        notesTableView.backgroundColor = .clear
    }
    
    func positionSubviews() {
        notesTableView.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 16, left: 16, bottom: 0, right: 16))
    }
}
