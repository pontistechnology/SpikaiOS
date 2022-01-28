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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView(enterUsernameView)
        setupBindings()
        setupImagePicker()
    }
    
    func setupBindings() {
        
        enterUsernameView.profilePictureView.tap().sink { [weak self] _ in
            guard let self = self else { return }
            self.present(self.imagePicker, animated: true, completion: nil)
        }.store(in: &subscriptions)
        
        enterUsernameView.nextButton.tap().sink { [weak self] _ in
            self?.viewModel.updateUsername(username: self?.enterUsernameView.usernameTextfield.text ?? " change")
        }.store(in: &subscriptions)
        
        viewModel.isUsernameWrong.sink { [weak self] isUsernameWrong in
            self?.enterUsernameView.errorView.isHidden = isUsernameWrong
        }.store(in: &subscriptions)
        
        
    
    }
}

extension EnterUsernameViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func setupImagePicker() {
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            enterUsernameView.profilePictureView.showImage(pickedImage)
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
