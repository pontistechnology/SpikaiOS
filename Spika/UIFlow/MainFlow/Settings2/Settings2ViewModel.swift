//
//  Settings2ViewModel.swift
//  Spika
//
//  Created by Nikola Barbarić on 10.11.2023..
//

import Foundation
import UIKit

class Settings2ViewModel: BaseViewModel, ObservableObject {
    @Published var user: User?
    @Published var selectedImage: UIImage?
    @Published var showImagePicker = false
    
    var selectedSource: UIImagePickerController.SourceType = .photoLibrary
    
    override init(repository: Repository, coordinator: Coordinator) {
        super.init(repository: repository, coordinator: coordinator)
        loadLocalUser()
    }
    
    var url: URL? {
        selectedImage == nil ? user?.avatarFileId?.fullFilePathFromId() : nil
    }
    
    private func loadLocalUser() {
        let ownId = self.repository.getMyUserId()
        self.repository.getLocalUser(withId: ownId)
            .receive(on: DispatchQueue.main)
            .sink { _ in
            } receiveValue: { [weak self] user in
                self?.user = user
            }.store(in: &self.subscriptions)
    }
    
    func onAppereanceClick() {
        getAppCoordinator()?.presentAppereanceSettingsScreen()
    }
    
    func onPrivacyClick() {
        getAppCoordinator()?.presentPrivacySettingsScreen()
    }
    
    func askForDeleteConformation() {
        // TODO: - change to loc. strings when design is ready
        getAppCoordinator()?.showAlert(title: "Delete Account?", message: "You will be logged out and ALL your data will be deleted.", style: .alert, actions: [.destructive(title: "Delete")])
            .sink(receiveValue: { [weak self] choice in
                self?.deleteMyAccount()
            }).store(in: &subscriptions)
    }
    
    func deleteMyAccount() {
        networkRequestState.send(.started())
        repository.deleteMyAccount().sink { [weak self] _ in
            self?.networkRequestState.send(.finished)
        } receiveValue: { [weak self] response in
            guard let isDeleted = response.data?.deleted, isDeleted
            else { return }
            self?.repository.deleteAllFiles()
            self?.repository.deleteUserDefaults()
            self?.repository.deleteLocalDatabase()
            self?.getAppCoordinator()?.start()
        }.store(in: &subscriptions)
    }
}

extension Settings2ViewModel {
    func showChangeImageActionSheet() {
        getAppCoordinator()?
            .showAlert(actions: [.regular(title: .getStringFor(.takeAPhoto)),
                                 .regular(title: .getStringFor(.chooseFromGallery)),
                                 .destructive(title: .getStringFor(.removePhoto))])
            .sink(receiveValue: { [weak self] tappedIndex in
                switch tappedIndex {
                case 0:
//                    self?.showUIImagePicker(source: .camera)
                    self?.selectedSource = .camera
                    self?.showImagePicker = true
                case 1:
                    self?.selectedSource = .photoLibrary
                    self?.showImagePicker = true
//                    self?.showUIImagePicker(source: .photoLibrary)
                case 2:
                    print("delete")
//                    self?.viewModel.onChangeUserAvatar(imageFileData: nil)
//                    self?.settingsView.userImage.deleteMainImage()
                default:
                    break
                }
            }).store(in: &subscriptions)
    }
}
