//
//  OneNoteViewModel.swift
//  Spika
//
//  Created by Nikola Barbarić on 07.08.2023..
//

import Foundation
import Combine

class OneNoteViewModel: BaseViewModel {
    var note: Note!
    
    let isEditingModePublisher = CurrentValueSubject<Bool, Never>(false)
    
    func updateNote(title: String, content: String) {
        note.title = title
        note.content = content
        networkRequestState.send(.started())
        repository.updateNote(note: note).sink { [weak self] _ in
            self?.networkRequestState.send(.finished)
        } receiveValue: { [weak self] response in
            guard let note = response.data?.note else { return }
            self?.note = note
        }.store(in: &subscriptions)
    }
}
