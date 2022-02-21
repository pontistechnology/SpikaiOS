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
    var image: UIImage?
    
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
            self.image = nil
            self.enterUsernameView.profilePictureView.deleteMainImage()
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    }
    
    func setupBindings() {
        
        enterUsernameView.profilePictureView.tap().sink { [weak self] _ in
            guard let self = self else { return }
            self.present(self.actionSheet, animated: true, completion: nil)
        }.store(in: &subscriptions)
        
        enterUsernameView.nextButton.tap().sink { [weak self] _ in
//            self?.viewModel.uploadPhoto(image: self!.image!)
            self?.viewModel.updateUsername(username: self?.enterUsernameView.usernameTextfield.text ?? "unknown")
            
        }.store(in: &subscriptions)
        
        viewModel.isUsernameWrong.sink { [weak self] isUsernameWrong in
            self?.enterUsernameView.errorView.isHidden = isUsernameWrong
        }.store(in: &subscriptions)
        
        sink(networkRequestState: viewModel.networkRequestState)
    
    }
}

extension EnterUsernameViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func setupImagePicker() {
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            image = pickedImage
            print("slika: ", info)
            enterUsernameView.profilePictureView.showImage(pickedImage)
        }
        
        if let file = info[UIImagePickerController.InfoKey.imageURL] as? URL {
            do {
                let imageData = try Data(contentsOf:file)
                let hash = imageData.getSHA256()
                print("SAD: ", hash)
            } catch {
                print(error)
            }
        }
    
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
