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
        super.init()
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
        self.chatDetailView.contentView.chatMembersView.ownId = self.viewModel.getMyUserId()
        
        let isAdmin = self.viewModel.room.map { [weak self] room in
            guard let self, room.type == .groupRoom else { return false }
            return room.users.filter { $0.userId == self.viewModel.getMyUserId() }.first?.isAdmin ?? false
        }
        
        if self.viewModel.room.value.type == .privateRoom {
            self.chatDetailView.contentView.blockButton.unhide()
            self.chatDetailView.contentView.leaveButton.hide()
        } else {
            self.chatDetailView.contentView.blockButton.hide()
            self.chatDetailView.contentView.leaveButton.unhide()
        }
        
        // View Model Binding
        self.viewModel.room
            .compactMap{ [weak self] room in
                if room.type == .groupRoom {
                    return room.avatarFileId?.fullFilePathFromId()
                } else {
                    guard let ownId = self?.viewModel.getMyUserId(),
                          let contact = self?.viewModel.room.value.users.first(where: { roomUser in
                        roomUser.userId != ownId
                    }) else { return nil }
                    return contact.user.avatarFileId?.fullFilePathFromId()
                }
            }
            .sink { [weak self] url in
                self?.chatDetailView.contentView.chatImage.showImage(url, placeholder: UIImage(safeImage: .userImage))
            }.store(in: &self.viewModel.subscriptions)

        self.viewModel.room
            .map { [weak self] room in
                if room.type == .privateRoom {
                    guard let ownId = self?.viewModel.getMyUserId(),
                          let contact = self?.viewModel.room.value.users.first(where: { roomUser in
                        roomUser.userId != ownId
                          }) else { return nil as String? }
                    return contact.user.displayName
                }
                return room.name
            }
            .sink { [weak self] chatName in
                self?.chatDetailView.contentView.chatName.text = chatName
                self?.chatDetailView.contentView.chatNameTextField.text = chatName
            }
            .store(in: &self.viewModel.subscriptions)

        self.viewModel.room
            .map { $0.users }
            .sink { [weak self] users in
                self?.chatDetailView.contentView.chatMembersView.updateWithMembers(users: users)
            }
            .store(in: &self.viewModel.subscriptions)
        
        self.viewModel.room
            .map { $0.muted }
            .sink { [weak self] isMuted in
                self?.chatDetailView.contentView.muteSwitchView.stateSwitch.isOn = isMuted
            }
            .store(in: &self.viewModel.subscriptions)
        
        self.viewModel.room
            .map { $0.pinned }
            .sink { [weak self] isMuted in
                self?.chatDetailView.contentView.pinChatSwitchView.stateSwitch.isOn = isMuted
            }
            .store(in: &self.viewModel.subscriptions)
        
        isAdmin
            .subscribe(self.chatDetailView.contentView.chatMembersView.editable)
            .store(in: &self.viewModel.subscriptions)
        
        isAdmin
            .sink(receiveValue: { [weak self] isAdmin in
                self?.chatDetailView.contentView.chatMembersView.addContactButton.isHidden = !isAdmin
                self?.chatDetailView.contentView.deleteButton.isHidden = !isAdmin
                self?.chatDetailView.contentView.chatImage.updateCameraIsHidden(isHidden: !isAdmin)
                self?.chatDetailView.contentView.chatName.isUserInteractionEnabled = isAdmin
            })
            .store(in: &self.viewModel.subscriptions)
        
        self.viewModel
            .uploadProgressPublisher
            .sink { [weak self] completion in
                self?.chatDetailView.contentView.chatImage.hideUploadProgress()
            } receiveValue: { [weak self] progress in
                guard let self else { return }
                self.chatDetailView.contentView.chatImage.showUploadProgress(progress: progress)
            }.store(in: &subscriptions)
        
        self.viewModel
            .isBlocked
            .map { isBlocked in
                return isBlocked ? String.getStringFor(.unblock) : .getStringFor(.block)
            }
            .sink { [weak self] string in
                self?.chatDetailView.contentView.blockButton.setTitle(string, for: .normal)
            }.store(in: &subscriptions)
        
        self.viewModel
            .room
            .map { $0.users.map{ $0.userId } }
            .filter { [weak self] userIds in
                guard let ownId = self?.viewModel.getMyUserId() else { return false }
                return !userIds.contains(ownId)
            }.sink { [weak self] string in
                self?.viewModel.getAppCoordinator()?.presentHomeScreen(startSyncAndSSE: true, startTab: .chat(withChatId: nil))
            }.store(in: &subscriptions)
        
        // UI Binding
        self.chatDetailView.contentView.chatName
            .tap()
            .withLatestFrom(isAdmin)
            .filter { $0.1 }
            .sink { [weak self] _ in
                self?.onChangeChatName()
            }.store(in: &self.subscriptions)
        
        self.chatDetailView.contentView.phoneNumberLabel.text = viewModel.getPhoneNumberText()
        self.chatDetailView.contentView.phoneNumberLabel.tap().sink { [weak self] _ in
            self?.phoneNumberLabelTapped()
        }.store(in: &subscriptions)
        
        self.chatDetailView.contentView.chatNameChanged
            .sink { [weak self] newName in
                self?.chatDetailView.contentView.chatNameTextField.hide()
                self?.viewModel.onChangeChatName(newName: newName)
            }.store(in: &self.subscriptions)
        
        self.chatDetailView.contentView
            .chatMembersView
            .onRemoveUser
            .sink { [weak self] indexPath in
                guard let user = self?.viewModel.room.value.users[indexPath.row].user else { return }
                self?.viewModel.removeUser(user: user)
            }.store(in: &self.chatDetailView.contentView.chatMembersView.subscriptions)
        
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
            .pinChatSwitchView
            .stateSwitch
            .publisher(for: .touchUpInside)
            .compactMap { [weak self] _ in
                self?.chatDetailView.contentView.pinChatSwitchView.stateSwitch.isOn
            }
            .sink { [weak self] value in
                self?.viewModel.pinUnpin(pin: value)
            }.store(in: &self.subscriptions)
        
        self.chatDetailView.contentView
            .chatMembersView
            .addContactButton
            .publisher(for: .touchUpInside)
            .sink { [weak self] _ in
                self?.viewModel.onAddNewUser()
            }.store(in: &self.subscriptions)
        
        self.chatDetailView.contentView
            .chatImage
            .tap()
            .withLatestFrom(isAdmin)
            .filter { $0.1 }
            .sink { [weak self] _ in
                self?.onChangeImage()
            }.store(in: &self.subscriptions)
        
        self.chatDetailView.contentView
            .deleteButton
            .tap()
            .sink { [weak self] _ in
                self?.viewModel.deleteRoom()
            }.store(in: &self.subscriptions)
        
        self.chatDetailView.contentView
            .leaveButton
            .tap()
            .sink { [weak self] _ in
                self?.onLeaveRoom()
            }.store(in: &self.subscriptions)
        
        self.chatDetailView.contentView
            .blockButton
            .tap()
            .sink { [weak self] _ in
                self?.viewModel.blockOrUnblock()
            }.store(in: &self.subscriptions)
        
        imagePickerPublisher.sink { [weak self] pickedImage in
            let photoStatus = pickedImage.statusOfPhoto(for: .avatar)
            switch photoStatus {
            case .allOk:
                guard let resizedImage = self?.viewModel.resizeImage(pickedImage) else { return }
                guard let data = resizedImage.jpegData(compressionQuality: 1) else { return }
                self?.viewModel.changeAvatar(image: data)
            default:
                self?.viewModel.showError(photoStatus.description)
            }
        }.store(in: &subscriptions)
    }
    
    func onChangeImage() {
        showChangeImageActionSheet()
    }
    
    func onLeaveRoom() {
        self.viewModel.getAppCoordinator()?.showAlert(title: .getStringFor(.areYouSureYoutWantToExitGroup),
                                            message: nil,
                                            style: .alert,
                                            actions: [AlertViewButton.destructive(title: .getStringFor(.yes))])
        .sink(receiveValue: { [weak self] tappedIndex in
            guard tappedIndex == 0 else { return }
            self?.viewModel.leaveRoomConfirmed()
//            self?.viewModel.getAppCoordinator()?.presentHomeScreen(startSyncAndSSE: true, startTab: .chat(withChatId: nil))
        })
        .store(in: &subscriptions)
    }
    
    func showChangeImageActionSheet() {
        viewModel
            .getAppCoordinator()?
            .showAlert(actions: [.regular(title: .getStringFor(.takeAPhoto)),
                                 .regular(title: .getStringFor(.chooseFromGallery)),
                                 .destructive(title: .getStringFor(.removePhoto))])
            .sink(receiveValue: { [weak self] tappedIndex in
                switch tappedIndex {
                case 0:
                    self?.showUIImagePicker(source: .camera)
                case 1:
                    self?.showUIImagePicker(source: .photoLibrary)
                case 2:
                    self?.viewModel.changeAvatar(image: nil)
                default:
                    break
                }
            }).store(in: &subscriptions)
    }
    
    func onChangeChatName() {
        self.chatDetailView.contentView.chatNameTextField.unhide()
        self.chatDetailView.contentView.chatNameTextField.becomeFirstResponder()
    }
    
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
        UIPasteboard.general.string = self.chatDetailView.contentView.phoneNumberLabel.text
        viewModel.showOneSecAlert(type: .copy)
    }
    
    func addToContacts() {
        guard let phoneNumber = self.chatDetailView.contentView.phoneNumberLabel.text,
              let name = self.chatDetailView.contentView.chatName.text
        else { return }
        viewModel.presentAddToContactsScreen(name: name, number: phoneNumber)
    }
}
