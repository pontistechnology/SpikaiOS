//
//  TapUtils.swift
//  Spika
//
//  Created by Marko on 22.10.2021..
//

import UIKit
import Combine

struct GesturePublisher: Publisher {
    typealias Output = UITapGestureRecognizer
    typealias Failure = Never
    
    private let view: UIView
    
    init(view: UIView) {
        self.view = view
    }
    
    func receive<S>(subscriber: S) where S : Subscriber,
    GesturePublisher.Failure == S.Failure, GesturePublisher.Output == S.Input {
        let subscription = GestureSubscription(
            subscriber: subscriber,
            view: view
        )
        subscriber.receive(subscription: subscription)
    }
}

class GestureSubscription<S: Subscriber>: Subscription where S.Input == UITapGestureRecognizer, S.Failure == Never {
    private var subscriber: S?
    private var view: UIView
    private let gesture = UITapGestureRecognizer()
    
    init(subscriber: S, view: UIView) {
        self.subscriber = subscriber
        self.view = view
        configureGesture()
    }
    
    private func configureGesture() {
        gesture.addTarget(self, action: #selector(handler))
        view.addGestureRecognizer(gesture)
    }
    
    func request(_ demand: Subscribers.Demand) { }
    
    func cancel() {
        subscriber = nil
    }
    
    @objc private func handler() {
        _ = subscriber?.receive(gesture)
    }
}

