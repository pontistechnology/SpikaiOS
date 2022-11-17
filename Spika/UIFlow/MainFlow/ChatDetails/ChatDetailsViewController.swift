//
//  ChatDetails.swift
//  Spika
//
//  Created by Vedran Vugrin on 10.11.2022..
//

import UIKit

final class ChatDetailsViewController: BaseViewController {
    
    private let viewModel: ChatDetailsViewModel
    private let chatDetailView = ChatDetailsView(frame: CGRectZero)
    
    init(viewModel: ChatDetailsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView(chatDetailView)
        setupBindings()
    }
    
    private func setupBindings() {
        // View Model Binding
        self.viewModel.groupImagePublisher
            .compactMap{ $0 }
            .subscribe(on: DispatchQueue.main)
            .sink { [weak self] url in
                self?.chatDetailView.contentView.chatImage.kf.setImage(with: url, placeholder: UIImage(safeImage: .userImage))
            }.store(in: &self.viewModel.subscriptions)

        self.viewModel.groupNamePublisher
            .sink { [weak self] chatName in
                self?.chatDetailView.contentView.chatName.text = chatName
            }.store(in: &self.viewModel.subscriptions)

        self.viewModel.groupContacts
            .sink { [weak self] users in
                self?.chatDetailView.contentView.chatMembersView.updateWithUsers(users: users)
            }.store(in: &self.viewModel.subscriptions)
        
        self.viewModel.isAdmin
            .subscribe(self.chatDetailView.contentView.chatMembersView.isAdmin)
            .store(in: &self.viewModel.subscriptions)
        
        self.viewModel.isAdmin
            .sink(receiveValue: { [weak self] isAdmin in
                self?.chatDetailView.contentView.chatMembersView
            })
            .store(in: &self.viewModel.subscriptions)
        
        // UI Binding
        self.chatDetailView.contentView
            .chatMembersView
            .onRemoveUser
            .sink { user in
                print("")
            }.store(in: &self.chatDetailView.contentView
                .chatMembersView.subscriptions)
        
        self.chatDetailView.contentView
            .muteSwitchView
            .stateSwitch
            .publisher(for: .touchUpInside)
            .compactMap { [weak self] _ in
                self?.chatDetailView.contentView.muteSwitchView.stateSwitch.isOn
            }
            .sink { [weak self] value in
                self?.viewModel.muteUnmute(mute: value)
            }.store(in: &self.subscriptions)
        
        self.chatDetailView.contentView
            .chatMembersView
            .addContactButton
            .publisher(for: .touchUpInside)
            .sink { [weak self] _ in
                self?.viewModel.onAddNewUser()
            }.store(in: &self.subscriptions)
    }
    
}
