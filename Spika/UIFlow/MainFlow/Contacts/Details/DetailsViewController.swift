//
//  DetailsViewController.swift
//  Spika
//
//  Created by Marko on 08.10.2021..
//

import UIKit
import AVFoundation


class DetailsViewController: BaseViewController {
    
    private let detailsView = DetailsView()
    var viewModel: DetailsViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView(detailsView)
        setupBindings()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    private func setupBindings() {
        detailsView.contentView.sharedMediaOptionButton.tap().sink { [weak self] _ in
            self?.viewModel.presentSharedScreen()
        }.store(in: &subscriptions)
        
        detailsView.contentView.chatSearchOptionButton.tap().sink { [weak self] _ in
            self?.viewModel.presentChatSearchScreen()
        }.store(in: &subscriptions)
        
        detailsView.contentView.favoriteMessagesOptionButton.tap().sink { [weak self] _ in
            self?.viewModel.presentFavoritesScreen()
        }.store(in: &subscriptions)
        
        detailsView.contentView.notesOptionButton.tap().sink { [weak self] _ in
            self?.viewModel.presentNotesScreen()
        }.store(in: &subscriptions)
        
        detailsView.contentView.callHistoryOptionButton.tap().sink { [weak self] _ in
            self?.viewModel.presentCallHistoryScreen()
        }.store(in: &subscriptions)
        
        detailsView.contentView.videoCallButton.tap().sink { [weak self] _ in
            guard let url = URL(string: "https://conference2.spika.chat/conference/spika3web") else { return }

            if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized,
               AVCaptureDevice.authorizationStatus(for: .audio) == .authorized {
                print("jes")
            } else {
                print("no")
            }
            
            self?.viewModel.presentVideoCallScreen(url: url)
        }.store(in: &subscriptions)
        
        detailsView.contentView.messageButton.tap().sink { [weak self] _ in
            guard let self else { return }
            self.viewModel.presentCurrentChatScreen()
        }.store(in: &subscriptions)
        
        viewModel.userSubject.receive(on: DispatchQueue.main).sink { [weak self] user in
            guard let self else { return }
            self.detailsView.contentView.nameLabel.text = user.getDisplayName()
            let url = user.avatarFileId?.fullFilePathFromId()
            self.detailsView.contentView.profilePhoto.kf.setImage(with: url, placeholder: UIImage(safeImage: .userImage))
        }.store(in: &subscriptions)
        
        self.detailsView.contentView.phoneNumberLabel.text = viewModel.getPhoneNumberText()
        self.detailsView.contentView.phoneNumberLabel.tap().sink { [weak self] _ in
            self?.phoneNumberLabelTapped()
        }.store(in: &subscriptions)
    }
    
    
    deinit {
//        print("DetailsViewController deinit")
    }
}

extension DetailsViewController {
    func phoneNumberLabelTapped() {
        viewModel
            .getAppCoordinator()?
            .showAlert(actions: [.regular(title: .getStringFor(.copy)),
                                 .regular(title: .getStringFor(.addToContacts))
            ], cancelText: .getStringFor(.cancel))
            .sink(receiveValue: { [weak self] tappedIndex in
                switch tappedIndex {
                case 0:
                    self?.copyPhoneNumber()
                case 1:
                    self?.addToContacts()
                default:
                    break
                }
            }).store(in: &subscriptions)
    }
    
    func copyPhoneNumber() {
        UIPasteboard.general.string = self.detailsView.contentView.phoneNumberLabel.text
        viewModel.showOneSecAlert(type: .copy)
    }
    
    func addToContacts() {
        guard let phoneNumber = self.detailsView.contentView.phoneNumberLabel.text,
              let name = self.detailsView.contentView.nameLabel.text
        else { return }
        viewModel.presentAddToContactsScreen(name: name, number: phoneNumber)
    }
}
