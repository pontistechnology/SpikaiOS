//
//  SettingsViewController.swift
//  Spika
//
//  Created by Marko on 21.10.2021..
//

import UIKit

class SettingsViewController: BaseViewController {
    
    private let settingsView = SettingsView()
    var viewModel: SettingsViewModel!
    
    var fileData: Data?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView(settingsView)
        setupBinding()
        settingsView.appVersion.text = "Build number: " + (Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "unknown")
    }
    
    func setupBinding() {
        // View model binding
        sink(networkRequestState: viewModel.networkRequestState)
        
        self.viewModel
            .user
            .compactMap { $0?.avatarFileId?.fullFilePathFromId() }
            .sink { c in
            } receiveValue: { [weak self] url in
                self?.settingsView.userImage.showImage(url, placeholder: UIImage(safeImage: .userImage))
            }.store(in: &self.subscriptions)
        
        self.viewModel
            .user
            .compactMap { $0?.displayName }
            .sink { c in
            } receiveValue: { [weak self] text in
                self?.settingsView.userName.setTitle(text, for: .normal)
                self?.settingsView.userNameTextField.text = text
            }.store(in: &self.subscriptions)
        
        self.viewModel
            .user
            .compactMap { $0?.telephoneNumber }
            .sink { c in
            } receiveValue: { [weak self] text in
                self?.settingsView.userPhoneNumber.setText(text: text)
            }.store(in: &self.subscriptions)
        
        // View binding
        self.settingsView.userName
            .tap()
            .sink { [weak self] _ in
                self?.onChangeUserName()
            }.store(in: &self.subscriptions)
        
        self.settingsView.userNameChanged
            .sink { [weak self] newName in
                self?.settingsView.userNameTextField.isHidden = true
                self?.viewModel.onChangeUserName(newName: newName)
            }.store(in: &self.subscriptions)
        
        self.settingsView.userImage.tap().sink { [weak self] _ in
            self?.showChangeImageActionSheet()
        }.store(in: &subscriptions)
        
        self.settingsView.privacyOptionButton
            .tap()
            .sink { [weak self] _ in
                self?.viewModel.getAppCoordinator()?.presentPrivacySettingsScreen()
            }.store(in: &subscriptions)
        
        self.imagePickerPublisher.sink { [weak self] selectedImage in
            let statusOfPhoto = selectedImage.statusOfPhoto(for: .avatar)
            switch statusOfPhoto {
            case .allOk:
                self?.settingsView.userImage.showImage(selectedImage)
                guard let data = selectedImage.jpegData(compressionQuality: 1) else { return }
                self?.viewModel.onChangeUserAvatar(imageFileData: data)
            default:
                self?.viewModel.showError(statusOfPhoto.description)
            }
        }.store(in: &subscriptions)
        

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
                    self?.fileData = nil
                    self?.settingsView.userImage.deleteMainImage()
                default:
                    break
                }
            }).store(in: &subscriptions)
    }
    
    func onChangeUserName() {
        self.settingsView.userNameTextField.isHidden = false
        self.settingsView.userNameTextField.becomeFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
}
