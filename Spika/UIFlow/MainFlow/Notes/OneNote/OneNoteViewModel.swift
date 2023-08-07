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
}
