//
//  Coordinator.swift
//  Spika
//
//  Created by Marko on 06.10.2021..
//

import UIKit

protocol Coordinator {
    var childCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController { get set }
    
    func start()
    
}
