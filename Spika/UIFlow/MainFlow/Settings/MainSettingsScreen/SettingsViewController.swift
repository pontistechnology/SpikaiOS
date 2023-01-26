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
    
    private let imagePicker = UIImagePickerController()
    let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    var fileData: Data?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView(settingsView)
        setupBinding()
        setupImagePicker()
        setupActionSheet()
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
            guard let self = self else { return }
            self.present(self.actionSheet, animated: true, completion: nil)
        }.store(in: &subscriptions)
        
        self.settingsView.privacyOptionButton
            .tap()
            .sink { [weak self] _ in
                self?.viewModel.getAppCoordinator()?.presentPrivacySettingsScreen()
            }.store(in: &subscriptions)
    }
    
    func setupActionSheet() {
        actionSheet.addAction(UIAlertAction(title:  .getStringFor(.takeAPhoto), style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            self.imagePicker.sourceType = .camera
            self.imagePicker.cameraCaptureMode = .photo
            self.imagePicker.cameraDevice = .front
            self.present(self.imagePicker, animated: true, completion: nil)
        }))
        actionSheet.addAction(UIAlertAction(title:  .getStringFor(.chooseFromHallery), style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        }))
        actionSheet.addAction(UIAlertAction(title:  .getStringFor(.removePhoto), style: .destructive, handler: { [weak self] _ in
            guard let self = self else { return }
            self.fileData = nil
            self.settingsView.userImage.deleteMainImage()
        }))
        actionSheet.addAction(UIAlertAction(title: .getStringFor(.cancel), style: .cancel, handler: nil))
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

extension SettingsViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
                self.settingsView.userImage.showImage(resizedImage)
                guard let data = resizedImage.jpegData(compressionQuality: 1) else { return }
                self.viewModel.onChangeUserAvatar(imageFileData: data)
            }
            dismiss(animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
