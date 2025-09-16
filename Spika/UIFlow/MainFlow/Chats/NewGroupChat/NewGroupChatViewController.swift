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
    var fileData: Data?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondaryColor
        setupView(newGroupChatView)
        setupBindings()
    }
    
    deinit {
        print("new group deinit")
    }
    
    func setupBindings() {
        // TODO: - dbr check with Vedran
        self.viewModel.selectedUsers
            .sink { [weak self] users in
                self?.newGroupChatView.chatMembersView.updateWithUsers(users: users)
            }.store(in: &self.viewModel.subscriptions)
        
        self.newGroupChatView.chatMembersView
            .onRemoveUser
//            .compactMap { $0 }
            .sink { [weak self] indexPath in
                guard let user = self?.viewModel.selectedUsers.value[indexPath.row] else { return }
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
        
        imagePickerPublisher.sink { [weak self] pickedImage in
            let photoStatus = pickedImage.statusOfPhoto(for: .avatar)
            switch photoStatus {
            case .allOk:
                guard let resizedImage = self?.viewModel.resizeImage(pickedImage) else { return }
                guard let data = resizedImage.jpegData(compressionQuality: 1) else { return }
                self?.newGroupChatView.avatarPictureView.setImage(resizedImage, for: .normal)
                self?.viewModel.fileData = data
            default:
                self?.viewModel.showError(photoStatus.description)
            }
        }.store(in: &subscriptions)
    }
    
    func onChangeImage() {
        showChangeImageActionSheet()
    }
    
    func showChangeImageActionSheet() {
        viewModel
            .getAppCoordinator()?
            .showAlert(actions: [.regular(title: .getStringFor(.takeAPhoto)),
                                 .regular(title: .getStringFor(.chooseFromGallery)),
                                 .destructive(title: .getStringFor(.removePhoto))],
                       viewController: self)
            .sink(receiveValue: { [weak self] tappedIndex in
                switch tappedIndex {
                case 0:
                    self?.showUIImagePicker(source: .camera)
                case 1:
                    self?.showUIImagePicker(source: .photoLibrary)
                case 2:
                    self?.viewModel.fileData = nil
                    self?.newGroupChatView.avatarPictureView.setImage(UIImage(resource: .camer), for: .normal)
                    break
                default:
                    break
                }
            }).store(in: &subscriptions)
    }
    
    override func setupView(_ view: UIView) {
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
        if let length = textField.text?.count {
            navigationItem.rightBarButtonItem?.isEnabled = length > 0
        }
    }
    
}

extension NewGroupChatViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
