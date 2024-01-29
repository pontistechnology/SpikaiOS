//
//  BaseViewModel.swift
//  Spika
//
//  Created by Marko on 06.10.2021..
//

import Foundation
import Combine
import UIKit

class BaseViewModel: NSObject {
    let coordinator: Coordinator
    let repository: Repository
    var subscriptions = Set<AnyCancellable>()
    let networkRequestState = CurrentValueSubject<RequestState, Never>(.finished)
    let actionPublisher: ActionPublisher?
    
    lazy var myUserId = getMyUserId() // use this, because there is no need to look in user defaults every time
    
    init(repository: Repository, coordinator: Coordinator, actionPublisher: ActionPublisher? = nil) {
        self.repository = repository
        self.coordinator = coordinator
        self.actionPublisher = actionPublisher
        super.init()
    }
    
    func getAppCoordinator() -> AppCoordinator? {
        return coordinator as? AppCoordinator
    }
    
    private func getMyUserId() -> Int64 {
        return repository.getMyUserId()
    }
    
    func showError(_ message: String) {
        getAppCoordinator()?.showError(message: message)
    }
    
    func showOneSecAlert(type: OneSecPopUpType) {
        _ = getAppCoordinator()?
            .showAlert(title: type.title, message: nil, style: .alert, actions: [], cancelText: nil)
    }
    
    // TODO: - move
    func resizeImage(_ original: UIImage) -> UIImage? {
        guard let jpgData = original.jpegData(compressionQuality: 1),
              let tempUrl = repository.saveDataToFile(jpgData, name: "tempFile"),
              let resizedImage = tempUrl.downsample(isForThumbnail: true)
        else { return nil }
        return resizedImage
    }
    
    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if error == nil {
            showOneSecAlert(type: .save)
        } else {
            showError("Error occured. Check permissions for photos.")
        }
    }
}
