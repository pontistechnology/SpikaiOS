//
//  KeyboardObserverAccessoryView.swift
//  Spika
//
//  Created by Nikola Barbarić on 02.08.2023..
//

import Foundation
import Combine
import UIKit

class KeyboardObserverAccessoryView: UIView {
    let publisher = PassthroughSubject<CGFloat, Never>()
    private var kvoContext: UInt8 = 1
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        if newSuperview == nil {
            self.superview?.removeObserver(self, forKeyPath: "center")
        } else{
            newSuperview?.addObserver(self, forKeyPath: "center", options: [NSKeyValueObservingOptions.new, NSKeyValueObservingOptions.initial], context: &kvoContext)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let theChange = change as [NSKeyValueChangeKey : AnyObject]?{
            if theChange[NSKeyValueChangeKey.newKey] != nil {
                guard let windowHeight = window?.screen.bounds.height,
                      let currentKeyboardVisibleHeight = superview?.frame.origin.y
                else { return }
                publisher.send(windowHeight - currentKeyboardVisibleHeight)
            }
        }
    }
    
}
