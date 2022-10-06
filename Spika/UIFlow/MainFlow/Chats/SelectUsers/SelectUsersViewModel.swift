//
//  SelectUsersViewModel.swift
//  Spika
//
//  Created by Nikola Barbarić on 20.02.2022..
//

import Foundation
import Combine

class SelectUsersViewModel: BaseViewModel {
    
    func getOnlineContacts(page: Int) {
        repository.getContacts(page: page).sink { [weak self] completion in
            guard let _ = self else { return }
            switch completion {
            case let .failure(error):
                print("get contacts error: ", error)
            default:
                break
            }
        } receiveValue: { [weak self] response in
            guard let self = self else { return }
            print("Success: ", response)
            if let list = response.data?.list {
//                self.updateContactsUI(list: list)
            }
            
        }.store(in: &subscriptions)
    }
    
    func presentNewGroupScreen() {
//        getAppCoordinator()?.presentNewGroupChatScreen(selectedMembers: selectedUsersSubject.value)
    }
}
