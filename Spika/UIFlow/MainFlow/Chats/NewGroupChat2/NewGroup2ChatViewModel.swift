//
//  NewChatViewModel.swift
//  Spika
//
//  Created by Nikola Barbarić on 23.11.2023..
//

import Foundation
import UIKit

class NewGroup2ChatViewModel: BaseViewModel, ObservableObject {
    @Published var showAddMembersScreen = false
    @Published var selectedMembers: [User] = []
    @Published var url: URL? = nil
    @Published var groupName = ""
    @Published var showImagePicker = false
    @Published var selectedImage: UIImage? {
        didSet {
            newImageChosen()
        }
    }
    var avatarId: Int64? = nil
    var selectedSource: UIImagePickerController.SourceType = .photoLibrary
    
    init(repository: Repository, coordinator: Coordinator, actionPublisher: ActionPublisher) {
        super.init(repository: repository, coordinator: coordinator, actionPublisher: actionPublisher)
        setupBindings()
    }
    
    func setupBindings() {
        actionPublisher?.sink { [weak self] action in
            switch action {
            case .newGroupFlowSelectUsers(let users):
                self?.selectedMembers.append(contentsOf: users)
            default:
                break
            }
        }.store(in: &subscriptions)
    }
    
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
            selectedImage = nil
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
            avatarId = file.id
            url = file.id?.fullFilePathFromId()
            selectedImage = nil
        }.store(in: &subscriptions)
    }
    
    func createGroup() {
        guard !groupName.isEmpty, !selectedMembers.isEmpty else { return }
        var userIds = selectedMembers.map { $0.id }
        userIds.append(myUserId)
        repository.createOnlineRoom(name: groupName, avatarId: avatarId, userIds: userIds).sink { c in
            print(c)
        } receiveValue: { [weak self] response in
            guard let room = response.data?.room else { return }
            self?.saveLocalRoom(room: room)
        }.store(in: &subscriptions)
    }
    
    func saveLocalRoom(room: Room) {
        repository.saveLocalRooms(rooms: [room])
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
            } receiveValue: { [weak self] rooms in
                guard let room = rooms.first else { return }
                self?.getAppCoordinator()?.popTopViewController()
                self?.getAppCoordinator()?.presentCurrentChatScreen(room: room)
            }.store(in: &subscriptions)
    }
}
