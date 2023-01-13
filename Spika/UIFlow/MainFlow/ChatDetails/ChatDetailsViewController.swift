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
    
    let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    private let imagePicker = UIImagePickerController()
    
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
        setupActionSheet()
        setupImagePicker()
    }
    
    private func setupBindings() {
        let isAdmin = self.viewModel.room.map { [weak self] room in
            guard let self = self else { return false }
            return room.users.filter { $0.userId == self.viewModel.getMyUserId() }.first?.isAdmin ?? false
        }
        
        if self.viewModel.room.value.users.count == 2 {
            self.chatDetailView.contentView.blockButton.isHidden = false
        }
        
        // View Model Binding
        self.viewModel.room
            .compactMap{ room in
                return room.avatarFileId?.fullFilePathFromId()
            }
            .sink { [weak self] url in
                self?.chatDetailView.contentView.chatImage.showImage(url, placeholder: UIImage(safeImage: .userImage))
            }.store(in: &self.viewModel.subscriptions)

        self.viewModel.room
            .map { $0.name }
            .sink { [weak self] chatName in
                self?.chatDetailView.contentView.chatName.text = chatName
            }.store(in: &self.viewModel.subscriptions)

        self.viewModel.room
            .map { $0.users }
            .sink { [weak self] users in
                self?.chatDetailView.contentView.chatMembersView.updateWithUsers(users: users)
            }.store(in: &self.viewModel.subscriptions)
        
        self.viewModel.room
            .map { $0.muted }
            .sink { [weak self] isMuted in
                self?.chatDetailView.contentView.muteSwitchView.stateSwitch.isOn = isMuted
            }
            .store(in: &self.viewModel.subscriptions)
        
        isAdmin
            .subscribe(self.chatDetailView.contentView.chatMembersView.isAdmin)
            .store(in: &self.viewModel.subscriptions)
        
        isAdmin
            .sink(receiveValue: { [weak self] isAdmin in
                self?.chatDetailView.contentView.chatMembersView.addContactButton.isHidden = !isAdmin
                self?.chatDetailView.contentView.deleteButton.isHidden = !isAdmin
            })
            .store(in: &self.viewModel.subscriptions)
        
        self.viewModel
            .uploadProgressPublisher
            .sink { [weak self] completion in
                self?.chatDetailView.contentView.chatImage.hideUploadProgress()
            } receiveValue: { [weak self] progress in
                guard let self = self else { return }
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
        
        // UI Binding
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
            .blockButton
            .tap()
            .sink { [weak self] _ in
                self?.viewModel.blockOrUnblock()
            }.store(in: &self.subscriptions)
    }
    
    func onChangeImage() {
        self.present(self.actionSheet, animated: true, completion: nil)
    }
    
    func setupActionSheet() {
        actionSheet.addAction(UIAlertAction(title: .getStringFor(.takeAPhoto), style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            self.imagePicker.sourceType = .camera
            self.imagePicker.cameraCaptureMode = .photo
            self.imagePicker.cameraDevice = .front
            self.present(self.imagePicker, animated: true, completion: nil)
        }))
        actionSheet.addAction(UIAlertAction(title: .getStringFor(.chooseFromHallery), style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        }))
        actionSheet.addAction(UIAlertAction(title: .getStringFor(.removePhoto), style: .destructive, handler: { [weak self] _ in
            guard let self = self else { return }
            
        }))
        actionSheet.addAction(UIAlertAction(title: .getStringFor(.cancel), style: .cancel, handler: nil))
    }
    
}

extension ChatDetailsViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func setupImagePicker() {
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            
            let widhtInPixels  = pickedImage.size.width * UIScreen.main.scale
            let heightInPixels = pickedImage.size.height * UIScreen.main.scale
            
            
            if widhtInPixels < 512 || heightInPixels < 512 {
                viewModel.showError(.getStringFor(.pleaseUserBetterQuality))
            } else if abs(widhtInPixels - heightInPixels) > 20 {
                viewModel.showError(.getStringFor(.pleaseSelectASquare))
            } else {
                guard let resizedImage = pickedImage.resizeImageToFitPixels(size: CGSize(width: 512, height: 512)) else { return }
                guard let data = resizedImage.jpegData(compressionQuality: 1) else { return }
                self.viewModel.changeAvatar(image: data)
            }
            self.dismiss(animated: true)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
