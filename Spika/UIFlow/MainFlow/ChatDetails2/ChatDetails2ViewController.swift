//
//  ChatDetails2ViewController.swift
//  Spika
//
//  Created by Nikola Barbarić on 13.11.2023..
//

import SwiftUI

class ChatDetails2ViewController: UIHostingController<ChatDetails2View> {
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}
