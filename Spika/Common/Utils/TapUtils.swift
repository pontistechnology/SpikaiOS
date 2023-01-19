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
    private let isLong: Bool
    
    init(view: UIView, isLong: Bool = false) {
        self.view = view
        self.isLong = isLong
    }
    
    func receive<S>(subscriber: S) where S : Subscriber,
    GesturePublisher.Failure == S.Failure, GesturePublisher.Output == S.Input {
        let subscription = GestureSubscription(
            subscriber: subscriber,
            view: view,
            isLong: isLong
        )
        subscriber.receive(subscription: subscription)
    }
}

class GestureSubscription<S: Subscriber>: Subscription where S.Input == UITapGestureRecognizer, S.Failure == Never {
    private var subscriber: S?
    private var view: UIView
    private let gesture = UITapGestureRecognizer()
    private let longTapGesture = UILongPressGestureRecognizer()
    
    init(subscriber: S, view: UIView, isLong: Bool) {
        self.subscriber = subscriber
        self.view = view
        configureGesture(isLong: isLong)
    }
    
    private func configureGesture(isLong: Bool) {
        gesture.addTarget(self, action: #selector(handler))
        longTapGesture.addTarget(self, action: #selector(handler))
        view.addGestureRecognizer(isLong ? longTapGesture : gesture)
    }
    
    func request(_ demand: Subscribers.Demand) { }
    
    func cancel() {
        subscriber = nil
    }
    
    @objc private func handler() {
        _ = subscriber?.receive(gesture)
    }
}

