//
//  TabBarItem.swift
//  Spika
//
//  Created by Marko on 21.10.2021..
//

import UIKit
import Combine

struct TabBarItem {
    let viewController: BaseViewController
    let title: String
    let image: String
    let position: Int
    var isSelected: Bool
    var indicationPublisher: AnyPublisher<String,Never>?
    var subscriptions = Set<AnyCancellable>()
}
