//
//  AppTests.swift
//  AppTests
//
//  Created by Marko on 27.10.2021..
//

import XCTest
import Swinject
import Combine
@testable import Spika

class AppTests: XCTestCase {

    var sut: ContactsViewModel!
    var subscriptions = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()
        let coordinator = AppCoordinator(navigationController: UINavigationController())
        sut = Assembler.sharedAssembler.resolver.resolve(ContactsViewModel.self, arguments: coordinator, RepositoryType.test)!
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func test_sers_requestSuccess() {
        sut.repository.getLocalUsers().sink { completion in
            switch completion {
            case let .failure(error):
                print("Could not get users: \(error)")
            default: break
            }
        } receiveValue: { users in
            XCTAssertEqual(2, users.count)
        }.store(in: &subscriptions)
        
    }
    
}
