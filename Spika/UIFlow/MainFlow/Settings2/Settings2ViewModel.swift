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
    @Published var selectedImage: UIImage? {
        didSet {
            newImageChosen()
        }
    }
    @Published var showImagePicker = false
    @Published var username = ""
    @Published var isEditingUsername = false {
        didSet {
            if !isEditingUsername && username != user?.getDisplayName() {
                updateInfo(username: username, avatarFileId: user?.avatarFileId ?? 0)
            }
        }
    }
    
    var selectedSource: UIImagePickerController.SourceType = .photoLibrary
    
    override init(repository: Repository, coordinator: Coordinator) {
        super.init(repository: repository, coordinator: coordinator)
        loadLocalUser()
    }
    
    var url: URL? {
        selectedImage == nil ? user?.avatarFileId?.fullFilePathFromId() : nil
    }
    
    private func loadLocalUser() {
        repository.getLocalUser(withId: myUserId)
            .receive(on: DispatchQueue.main)
            .sink { _ in
            } receiveValue: { [weak self] user in
                self?.user = user
                self?.username = user.getDisplayName()
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
                    self?.selectedSource = .camera
                    self?.showImagePicker = true
                case 1:
                    self?.selectedSource = .photoLibrary
                    self?.showImagePicker = true
                case 2:
                    self?.onChangeUserAvatar(imageFileData: nil)
                default:
                    break
                }
            }).store(in: &subscriptions)
    }
    
    private func newImageChosen() {
        guard let selectedImage else { return }
        let statusOfPhoto = selectedImage.statusOfPhoto(for: .avatar)
        switch statusOfPhoto {
        case .allOk:
            guard let resizedImage = resizeImage(selectedImage),
                  let data = resizedImage.jpegData(compressionQuality: 1) 
            else { return }
            onChangeUserAvatar(imageFileData: data)
        default:
            showError(statusOfPhoto.description)
            self.selectedImage = nil
        }
    }
    
    private func onChangeUserAvatar(imageFileData: Data?) {
        guard let imageFileData = imageFileData,
              let fileUrl = repository.saveDataToFile(imageFileData, name: "newAvatar")
        else {
            updateInfo(username: user?.getDisplayName() ?? "", avatarFileId: 0)
            return
        }
        
        let tuple = repository.uploadWholeFile(fromUrl: fileUrl, mimeType: "image/*", metaData: MetaData(width: 512, height: 512, duration: 0), specificFileName: nil)
        tuple.sink { [weak self] completion in
            guard let self else { return }
            switch completion {
            case .finished:
                break
            case let .failure(error):
                self.showError("Error with file upload: \(error)")
            }
        } receiveValue: { [weak self] (file, percent) in
            guard let self else { return }
            guard let file = file else { return }
            updateInfo(username: self.user?.getDisplayName() ?? "", avatarFileId: file.id ?? 0)
        }.store(in: &subscriptions)
    }
    
    private func updateInfo(username: String, avatarFileId: Int64) {
        networkRequestState.send(.started())
        repository.updateUser(username: username, avatarFileId: avatarFileId, telephoneNumber: nil, email: nil)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                networkRequestState.send(.finished)
                switch completion {
                case let .failure(error):
                    showError("Username error: \(error)")
                case .finished:
                    break
                }
                selectedImage = nil
            } receiveValue: { [weak self] response in
                guard let self,
                      let user = response.data?.user else { return }
                saveUser(user: user)
            }.store(in: &subscriptions)
    }
    
    private func saveUser(user: User) {
        repository.saveUsers([user])
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let _ = self else { return }
                switch completion {
                case let .failure(error):
                    print("Could not save user: \(error)")
                default: break
                }
            } receiveValue: { [weak self] users in
                guard users.count == 1, let user = users.first else { return }
                self?.user = user
            }.store(in: &subscriptions)

    }
}
