//
//  BaseViewController.swift
//  Spika
//
//  Created by Marko on 06.10.2021..
//

import UIKit
import Combine

class BaseViewController: UIViewController {
    
    var subscriptions = Set<AnyCancellable>()
    private let circularProgressBar = CircularProgressBar(spinnerWidth: 24)
    let imagePickerPublisher = PassthroughSubject<UIImage, Never>()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
//        let name = String(describing: self.self)
//        print("\(name) deinit")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barStyle = .default
        navigationController?.setNavigationBarHidden(false, animated: animated)
        UITextField.appearance().tintColor = UIColor.systemTeal
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func setupView(_ view: UIView) {
        self.view.backgroundColor = .appWhite
        self.view.addSubview(view)
        view.fillSuperviewSafeAreaLayoutGuide()
        hideKeyboardWhenTappedAround()
    }
    
    // TODO: - move
    private func showLoading(progress: CGFloat?) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if let _ = self.circularProgressBar.superview {
                print("jes")
            } else {
                self.view.addSubview(self.circularProgressBar)
                self.circularProgressBar.anchor(top: self.view.topAnchor, leading: self.view.leadingAnchor, bottom: self.view.bottomAnchor, trailing: self.view.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
            }
            
            if let progress = progress {
                self.circularProgressBar.setProgress(to: progress)
            } else {
                self.circularProgressBar.startSpinning()
            }
        }
    }
    
    private func hideLoading() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.circularProgressBar.removeFromSuperview()
        }
    }
    
    func sink(networkRequestState publisher: CurrentValueSubject<RequestState, Never>) {
        publisher.sink { [weak self] state in
            guard let self = self else { return }
            switch state {
            case .finished:
                self.hideLoading()
            case .started(let progress):
                self.showLoading(progress: progress)
            }
        }.store(in: &subscriptions)
    }
}

extension BaseViewController {
    func hideKeyboardWhenTappedAround() {
            let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
            tap.cancelsTouchesInView = false
            view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: UIImagepicker

extension BaseViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func showUIImagePicker(source: UIImagePickerController.SourceType, allowsEdit: Bool = true) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = source
        imagePicker.delegate = self
        imagePicker.allowsEditing = allowsEdit
        if case UIImagePickerController.SourceType.camera = source {
            imagePicker.cameraCaptureMode = .photo
            imagePicker.cameraDevice = .front
        }
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // TODO: send url
        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            imagePickerPublisher.send(pickedImage)
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imagePickerPublisher.send(originalImage)
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

