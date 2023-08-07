//
//  NotesViewModel.swift
//  Spika
//
//  Created by Nikola Barbarić on 11.02.2022..
//

import Foundation
import Combine

class AllNotesViewModel: BaseViewModel {
    var roomId: Int64!
    let notesPublisher = CurrentValueSubject<[Note], Error>([])
    
    func getAllNotes() {
        repository.getAllNotes(roomId: roomId).sink { _ in
            
        } receiveValue: { [weak self] response in
            guard let notes = response.data?.notes else { return }
            self?.notesPublisher.send(notes)
        }.store(in: &subscriptions)
    }
    
    func presentOneNoteScreen(noteState: NoteState) {
        getAppCoordinator()?.presentOneNoteScreen(noteState: noteState)
    }
    
    func askToDelete(note: Note) {
        var actions: [AlertViewButton] = [.destructive(title: .getStringFor(.delete)), .regular(title: .getStringFor(.cancel))]
        getAppCoordinator()?
            .showAlert(title: "Are you sure?", message: "This note will be deleted.", style: .alert, actions: actions, cancelText: nil)
            .sink(receiveValue: { [weak self] tappedIndex in
                switch tappedIndex {
                case 0:
                    self?.deleteNote(id: note.id)
                default:
                    break
                }
            }).store(in: &subscriptions)
    }
    
    func deleteNote(id: Int64) {
        repository.deleteNote(id: id).sink { c in
            print(c)
        } receiveValue: { [weak self] _ in
            self?.getAllNotes()
        }.store(in: &subscriptions)
    }
}
