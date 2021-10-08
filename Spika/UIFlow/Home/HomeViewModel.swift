//
//  HomeViewModel.swift
//  Spika
//
//  Created by Marko on 06.10.2021..
//

import Foundation
import Combine

class HomeViewModel: BaseViewModel {
    
    func getPosts() {
        self.repository.getPosts().sink { completion in
            switch completion {
            case let .failure(error):
                print("Could not get posts: \(error)")
            default: break
            }
        } receiveValue: { posts in
            print(posts)
        }.store(in: &subscriptions)
    }
    
    func showDetailsScreen(id: Int) {
        getAppCoordinator()?.presentDetailsScreen(id: id)
    }
    
}
