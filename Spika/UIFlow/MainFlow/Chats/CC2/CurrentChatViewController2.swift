//
//  CurrentChatViewController2.swift
//  Spika
//
//  Created by Nikola Barbarić on 27.11.2023..
//

import Foundation
import SwiftUI

class CurrentChatViewController2: UIHostingController<AnyView> {
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}
