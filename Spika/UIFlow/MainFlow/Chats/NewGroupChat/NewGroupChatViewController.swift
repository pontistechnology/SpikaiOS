//
//  NewGroupChatViewController.swift
//  Spika
//
//  Created by Nikola Barbarić on 07.03.2022..
//

import Foundation
import UIKit

class NewGroupChatViewController: BaseViewController {
    
    lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    } ()
    
    private let newGroupChatView = NewGroupChatView()
    
    var viewModel: NewGroupChatViewModel!
    private let imagePicker = UIImagePickerController()
    let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    var fileData: Data?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView(newGroupChatView)
        setupBindings()
        setupImagePicker()
        setupActionSheet()
    }
    
    func setupBindings() {
        self.viewModel.selectedUsers
            .sink { [weak self] users in
                self?.newGroupChatView.chatMembersView.updateWithUsers(users: users.map { RoomUser(user: $0) })
            }.store(in: &self.viewModel.subscriptions)
        
        self.newGroupChatView.chatMembersView
            .onRemoveUser
            .compactMap { $0 }
            .sink { [weak self] user in
                self?.viewModel.removeUser(user: user)
            }.store(in: &self.viewModel.subscriptions)
        
        self.newGroupChatView.avatarPictureView
            .tap()
            .sink { [weak self] _ in
                self?.onChangeImage()
            }.store(in: &self.viewModel.subscriptions)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: .getStringFor(.create), style: .plain, target: self, action: #selector(createButtonHandler))
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        newGroupChatView.groupNameTextfield.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        newGroupChatView.groupNameTextfield.delegate = self
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
        actionSheet.addAction(UIAlertAction(title: .getStringFor(.cancel), style: .cancel, handler: nil))
    }
    
    func onChangeImage() {
        self.present(self.actionSheet, animated: true, completion: nil)
    }
    
    override func setupView(_ view: UIView) {
        self.view.backgroundColor = .white
        self.view.addSubview(self.scrollView)
        self.scrollView.constraint()
        
        self.scrollView.addSubview(view)
        view.constraintToGuide(guide: self.scrollView.contentLayoutGuide)
        view.equalWidth(to: self.view)
    }
    
    @objc func createButtonHandler() {
        guard let name = newGroupChatView.groupNameTextfield.text else { return }
        viewModel.createRoom(name: name)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if let length = textField.text?.count, length > 3 {
            navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
}

extension NewGroupChatViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension NewGroupChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
                self.newGroupChatView.avatarPictureView.setImage(resizedImage, for: .normal)
//                enterUsernameView.profilePictureView.showImage(resizedImage)
                self.viewModel.fileData = resizedImage.jpegData(compressionQuality: 1)
            }
            dismiss(animated: true, completion: nil)
        }
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
