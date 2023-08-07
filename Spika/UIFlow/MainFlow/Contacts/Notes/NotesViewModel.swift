//
//  NotesViewModel.swift
//  Spika
//
//  Created by Nikola Barbarić on 11.02.2022..
//

import Foundation
import Combine

class NotesViewModel: BaseViewModel {
    var roomId: Int64!
    let notesPublisher = CurrentValueSubject<[Note], Error>([])
    
    func getAllNotes() {
        repository.getAllNotes(roomId: roomId).sink { _ in
            
        } receiveValue: { [weak self] response in
            guard let notes = response.data?.notes else { return }
            self?.notesPublisher.send(notes)
        }.store(in: &subscriptions)
    }
}
