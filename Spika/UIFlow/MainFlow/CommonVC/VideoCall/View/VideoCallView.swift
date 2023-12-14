//
//  VideoCallView.swift
//  Spika
//
//  Created by Nikola Barbarić on 16.02.2022..
//

import Foundation
import UIKit
import WebKit

class VideoCallView: WKWebView, BaseView{
    
    let urlToOpen: URL
    
    init(url: URL) {
        urlToOpen = url
        
        let preferences = WKWebpagePreferences()
        let configuration = WKWebViewConfiguration()
        
        preferences.allowsContentJavaScript = true
        configuration.defaultWebpagePreferences = preferences
        configuration.allowsInlineMediaPlayback = true
        
        super.init(frame: .zero, configuration: configuration)
        load(URLRequest(url: url))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func addSubviews() {
        
    }
    
    func styleSubviews() {
        
    }
    
    func positionSubviews() {
        
    }

}
