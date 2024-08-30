//
//  ShareViewController.swift
//  Share Extension
//
//  Created by Nikola Barbarić on 22.08.2024..
//

import UIKit
import Social
import SwiftUI
import UniformTypeIdentifiers
import CryptoKit


class ShareViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .purple
        
        guard let extensionContext,
              let itemProviders = (extensionContext.inputItems.first as? NSExtensionItem)?.attachments
        else {
            return
        }
        
        let rV = SelectUsersOrGroupView(viewModel: SelectUsersOrGroupsViewModel(itemProviders: itemProviders, extensionContext: extensionContext))
            .environment(\.managedObjectContext, CoreDataStack().mainMOC)
        
        let hostingView = UIHostingController(rootView: rV)
        hostingView.view.frame = view.frame
        view.addSubview(hostingView.view)
    }
}
