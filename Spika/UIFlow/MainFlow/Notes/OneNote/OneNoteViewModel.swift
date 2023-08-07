//
//  OneNoteViewModel.swift
//  Spika
//
//  Created by Nikola Barbarić on 07.08.2023..
//

import Foundation
import Combine

class OneNoteViewModel: BaseViewModel {
    var noteStatePublisher: CurrentValueSubject<NoteState, Never>!
    
    func editNote(title: String, content: String, id: Int64) {
        networkRequestState.send(.started())
        repository.updateNote(title: title, content: content, id: id).sink { [weak self] _ in
            self?.networkRequestState.send(.finished)
        } receiveValue: { [weak self] response in
            guard let note = response.data?.note else { return }
            self?.noteStatePublisher.send(.viewing(note: note))
        }.store(in: &subscriptions)
    }
    
    func createNote(title: String, content: String, roomId: Int64) {
        networkRequestState.send(.started())
        repository.createNote(title: title, content: content, roomId: roomId).sink { [weak self] _ in
            self?.networkRequestState.send(.finished)
        } receiveValue: { [weak self] response in
            guard let note = response.data?.note else { return }
            self?.noteStatePublisher.send(.viewing(note: note))
        }.store(in: &subscriptions)

    }
}
