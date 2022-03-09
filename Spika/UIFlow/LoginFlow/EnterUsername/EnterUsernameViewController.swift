//
//  EnterUsernameViewController.swift
//  Spika
//
//  Created by Nikola Barbarić on 25.01.2022..
//

import UIKit

class EnterUsernameViewController: BaseViewController {
    
    private let enterUsernameView = EnterUsernameView()
    var viewModel: EnterUsernameViewModel!
    private let imagePicker = UIImagePickerController()
    let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    var fileData: Data?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView(enterUsernameView)
        setupBindings()
        setupImagePicker()
        setupActionSheet()
    }
    
    func setupActionSheet() {
        actionSheet.addAction(UIAlertAction(title: "Take a photo", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            self.imagePicker.sourceType = .camera
            self.imagePicker.cameraCaptureMode = .photo
            self.imagePicker.cameraDevice = .front
            self.present(self.imagePicker, animated: true, completion: nil)
        }))
        actionSheet.addAction(UIAlertAction(title: "Choose from gallery", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        }))
        actionSheet.addAction(UIAlertAction(title: "Remove photo", style: .destructive, handler: { [weak self] _ in
            guard let self = self else { return }
            self.fileData = nil
            self.enterUsernameView.profilePictureView.deleteMainImage()
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    }
    
    func setupBindings() {
        sink(networkRequestState: viewModel.networkRequestState)
        
        enterUsernameView.profilePictureView.tap().sink { [weak self] _ in
            guard let self = self else { return }
            self.present(self.actionSheet, animated: true, completion: nil)
        }.store(in: &subscriptions)
        
        enterUsernameView.nextButton.tap().sink { [weak self] _ in
            if let username = self?.enterUsernameView.usernameTextfield.text {
                self?.viewModel.updateUser(username: username, imageFileData: self?.fileData)
            }
        }.store(in: &subscriptions)
    }
}

extension EnterUsernameViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func setupImagePicker() {
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            
            let widhtInPixels  = pickedImage.size.width * UIScreen.main.scale
            let heightInPixels = pickedImage.size.height * UIScreen.main.scale
            
            if widhtInPixels < 512 || heightInPixels < 512 {
                PopUpManager.shared.presentAlert(errorMessage: "Please use better quality.")
            } else if abs(widhtInPixels - heightInPixels) > 5 {
                PopUpManager.shared.presentAlert(errorMessage: "Please select a square")
            } else {
                guard let resizedImage = pickedImage.resizeImageToFitPixels(size: CGSize(width: 512, height: 512)) else { return }
                enterUsernameView.profilePictureView.showImage(resizedImage)
                fileData = resizedImage.jpegData(compressionQuality: 1)
            }
            dismiss(animated: true, completion: nil)
        }
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
