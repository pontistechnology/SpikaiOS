//
//  NewPrivateChatViewController2.swift
//  Spika
//
//  Created by Nikola Barbarić on 12.09.2024..
//

import UIKit
import SwiftUI
import CoreData

class NewPrivateChatViewController2: UIHostingController<AnyView> {
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    init(rootView: NewPrivateChatView, context: NSManagedObjectContext) {
        let a = rootView.environment(\.managedObjectContext, context)
        super.init(rootView: AnyView(a))
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
