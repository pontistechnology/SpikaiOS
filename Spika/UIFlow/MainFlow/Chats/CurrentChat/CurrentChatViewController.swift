//
//  CurrentViewController.swift
//  Spika
//
//  Created by Nikola Barbarić on 22.02.2022..
//

import Foundation
import UIKit
import CoreData
import PhotosUI
import Combine
import UniformTypeIdentifiers

struct SelectedFile {
    let fileType: UTType
    let name: String?
    let fileUrl: URL
    let thumbnail: UIImage
}

class CurrentChatViewController: BaseViewController {
    
    private let currentChatView = CurrentChatView()
    var viewModel: CurrentChatViewModel!
    let friendInfoView = ChatNavigationBarView()
    var frc: NSFetchedResultsController<MessageEntity>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView(currentChatView)
        setupNavigationItems()
        setupBindings()
        checkRoom()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        guard let room = viewModel.room else { return }
        viewModel.roomVisited(roomId: room.id)
    }
    
    deinit {
        print("currentChatVC deinit")
    }
}

// MARK: Functions

extension CurrentChatViewController {
    func checkRoom() {
        viewModel.checkLocalRoom()
    }
    
    func setupBindings() {
        currentChatView.messageInputView.delegate = self
        currentChatView.messagesTableView.delegate = self
        currentChatView.messagesTableView.dataSource = self
        sink(networkRequestState: viewModel.networkRequestState)
        
        viewModel.roomPublisher.receive(on: DispatchQueue.main).sink { [weak self] completion in
            // TODO: pop vc?, presentAlert?
            guard let self = self else { return }
            switch completion {
                
            case .finished:
                break
            case let .failure(error):
                PopUpManager.shared.presentAlert(with: (title: "Error", message: error.localizedDescription), orientation: .horizontal, closures: [("Ok", {
                    self.viewModel.getAppCoordinator()?.popTopViewController()
                })])
            }
        } receiveValue: { [weak self] room in
            guard let self = self else { return }
            self.setFetch(room: room)
            self.setupNavigationItems()
        }.store(in: &subscriptions)
        
        currentChatView.downArrowImageView.tap().sink { [weak self] _ in
            self?.currentChatView.messagesTableView.scrollToBottom()
        }.store(in: &subscriptions)
        
        viewModel.selectedFiles.receive(on: DispatchQueue.main).sink { [weak self] files in
            guard let self = self else { return }
            if files.isEmpty {
                self.currentChatView.messageInputView.hideSelectedFiles()
            } else {
                print("FILES COUNT: ", files.count)
                self.currentChatView.messageInputView.showSelectedFiles(files)
                
                let arrangedSubviews = self.currentChatView.messageInputView.selectedFilesView.itemsStackView.arrangedSubviews
                
                arrangedSubviews.forEach { view in
                    if let iw = view as? SelectedFileImageView {
                        iw.deleteImageView.tap().sink { [weak self] _ in
                            guard let self = self,
                                  let index =  arrangedSubviews.firstIndex(of: view)
                            else { return }
                            self.viewModel.selectedFiles.value.remove(at: index)
                        }.store(in: &self.subscriptions)
                    }
                }
            }
        }.store(in: &subscriptions)
        
        viewModel.uploadProgressPublisher.sink { [weak self] (index, progress) in
            guard let self = self else { return }
            if let arrangedSubviews = self.currentChatView.messageInputView.selectedFilesView.itemsStackView.arrangedSubviews as? [SelectedFileImageView] {
                arrangedSubviews[index].showUploadProgress(progress: progress)
            }
            
        }.store(in: &subscriptions)
    }
}

// MARK: - NSFetchedResultsController

extension CurrentChatViewController: NSFetchedResultsControllerDelegate {
    
    func setFetch(room: Room) {
        let fetchRequest = MessageEntity.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "createdDate", ascending: true),
            NSSortDescriptor(key: #keyPath(MessageEntity.createdAt), ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "room.id == %d", room.id)
        self.frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.viewModel.repository.getMainContext(), sectionNameKeyPath: "sectionName", cacheName: nil)
        self.frc?.delegate = self
        do {
            try self.frc?.performFetch()
            self.currentChatView.messagesTableView.reloadData()
            self.currentChatView.messagesTableView.layoutIfNeeded()
            self.currentChatView.messagesTableView.scrollToBottom()
        } catch {
            fatalError("Failed to fetch entities: \(error)") // TODO: handle error
        }
        
        viewModel.roomVisited(roomId: room.id)
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        currentChatView.messagesTableView.beginUpdates()
    }
    
    // MARK: - sections
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            print("DIDCHANGE: sections insert")
            currentChatView.messagesTableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            print("DIDCHANGE: sections delete")
            currentChatView.messagesTableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        case .move:
            print("DIDCHANGE: sections move")
            break
        case .update:
            print("DIDCHANGE: sections update")
            break
        @unknown default:
            break
        }
    }
    
    // MARK: - rows
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        print("TYPE: ", type.rawValue)
        switch type {
        case .insert:
            print("DIDCHANGE: rows insert")
            guard let newIndexPath = newIndexPath else {
                return
            }
            currentChatView.messagesTableView.insertRows(at: [newIndexPath], with: .fade)
        case .delete:
            print("DIDCHANGE: rows delete")
            guard let indexPath = indexPath else {
                return
            }
            currentChatView.messagesTableView.deleteRows(at: [indexPath], with: .none)
        case .move:
            print("DIDCHANGE: rows move")
            guard let indexPath = indexPath,
                  let newIndexPath = newIndexPath
            else {
                return
            }
            currentChatView.messagesTableView.moveRow(at: indexPath, to: newIndexPath)
            
        case .update:
            print("DIDCHANGE: rows update")
            guard let indexPath = indexPath else {
                return
            }
            UIView.performWithoutAnimation {
                currentChatView.messagesTableView.reloadRows(at: [indexPath], with: .none)
            }
        default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        currentChatView.messagesTableView.endUpdates()
        currentChatView.messagesTableView.scrollToBottom()
    }
}


// MARK: - MessageInputView actions

extension CurrentChatViewController: MessageInputViewDelegate {
    
    func messageInputView(_ messageVeiw: MessageInputView, didPressSend message: String) {
        print("send in ccVC ")
        
        viewModel.trySendMessage(text: message)
        currentChatView.messageInputView.clearTextField()
    }
    
    func messageInputView(didPressCameraButton messageVeiw: MessageInputView) {
        print("camera in ccVC")
    }
    
    func messageInputView(didPressMicrophoneButton messageVeiw: MessageInputView) {
        print("mic in ccVC")
    }
    
    func messageInputView(didPressLibraryButton messageVeiw: MessageInputView) {
        presentLibraryPicker()
    }
    
    func messageInputView(didPressFilesButton messageVeiw: MessageInputView) {
        presentFilePicker()
    }
    
    func messageInputView(didPressEmojiButton messageVeiw: MessageInputView) {
        print("emoji in ccVC")
    }
}

// MARK: - UITableView

extension CurrentChatViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? TextMessageTableViewCell else { return }
        (tableView.visibleCells as? [TextMessageTableViewCell])?.forEach{ $0.setTimeLabelVisible(false)}
        cell.tapHandler()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let lastIndexPath = tableView.lastCellIndexPath,
              let shouldHide = tableView.indexPathsForVisibleRows?.contains(lastIndexPath)
        else { return }
        currentChatView.hideScrollToBottomButton(should: shouldHide)
    }
}

extension CurrentChatViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.frc?.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = self.frc?.sections else { return 0 }
        return sections[section].numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let entity = frc?.object(at: indexPath) else { return UITableViewCell()}
        let message = Message(messageEntity: entity)
        guard let identifier = getIdentifierFor(message: message) else { return UITableViewCell() }
        let myUserId = viewModel.repository.getMyUserId()
        
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? BaseMessageTableViewCell
        
        switch message.type {
        case .text:
            (cell as? TextMessageTableViewCell)?.updateCell(message: message)
        case .image:
            (cell as? ImageMessageTableViewCell)?.updateCell(message: message)
        case .file:
            (cell as? FileMessageTableViewCell)?.updateCell(message: message)
        case .unknown, .video, .voice, .audio, .none:
            break
        }
        
        cell?.updateCellState(to: message.getMessageState(myUserId: myUserId))
        if let user = viewModel.getUser(for: message.fromUserId) {
            if shouldDisplaySenderName(for: indexPath) {
                cell?.updateSender(name: user.getDisplayName())
            }
            if shouldDisplaySenderPhoto(for: indexPath) {
                cell?.updateSender(photoUrl: URL(string: user.getAvatarUrl() ?? ""))
            }
        }
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let sections = self.frc?.sections else { return nil }
        var name = sections[section].name
        if let time = (sections[section].objects?.first as? MessageEntity)?.createdAt {
            name.append(", ")
            name.append(time.convert(to: .HHmm))
        }
        let dateLabel = CustomLabel(text: name, textSize: 11, textColor: .textPrimary, fontName: .MontserratMedium, alignment: .center)
        return dateLabel
    }
    
    func shouldDisplaySenderName(for indexPath: IndexPath) -> Bool {
        let previousRow = indexPath.row - 1
        if previousRow >= 0 {
            let currentMessageEntity  = frc?.object(at: indexPath)
            let previousMessageEntity = frc?.object(at: IndexPath(row: previousRow,
                                                                  section: indexPath.section))
            return currentMessageEntity?.fromUserId != previousMessageEntity?.fromUserId
        }
        return true
    }
    
    func shouldDisplaySenderPhoto(for indexPath: IndexPath) -> Bool {
        guard let sections = frc?.sections else { return true }
        let maxRowsIndex = sections[indexPath.section].numberOfObjects - 1
        let nextRow = indexPath.row + 1
        if nextRow <= maxRowsIndex {
            let currentMessageEntity  = frc?.object(at: indexPath)
            let nextMessageEntity = frc?.object(at: IndexPath(row: nextRow,
                                                              section: indexPath.section))
            return currentMessageEntity?.fromUserId != nextMessageEntity?.fromUserId
        }
        return true
    }
    
    func getIdentifierFor(message: Message) -> String? {
        let myUserId = viewModel.repository.getMyUserId()
        switch message.type {
        case .text:
            if myUserId == message.fromUserId {
                return TextMessageTableViewCell.myTextReuseIdentifier
            } else if viewModel.room?.type == .privateRoom {
                return TextMessageTableViewCell.friendTextReuseIdentifier
            } else {
                return TextMessageTableViewCell.groupTextReuseIdentifier
            }
        case .image:
            if myUserId == message.fromUserId {
                return ImageMessageTableViewCell.myImageReuseIdentifier
            } else if viewModel.room?.type == .privateRoom {
                return ImageMessageTableViewCell.friendImageReuseIdentifier
            } else {
                return ImageMessageTableViewCell.groupImageReuseIdentifier
            }
        case .file:
            if myUserId == message.fromUserId {
                return FileMessageTableViewCell.myFileReuseIdentifier
            } else if viewModel.room?.type == .privateRoom {
                return FileMessageTableViewCell.friendFileReuseIdentifier
            } else {
                return FileMessageTableViewCell.groupFileReuseIdentifier
            }
        case .unknown, .voice, .audio, .video, .none:
            return nil
        }
    }
}

// MARK: - Navigation items setup

extension CurrentChatViewController {
    func setupNavigationItems() {
        let videoCallButton = UIBarButtonItem(image: UIImage(safeImage: .videoCall), style: .plain, target: self, action: #selector(videoCallActionHandler))
        let audioCallButton = UIBarButtonItem(image: UIImage(safeImage: .phoneCall), style: .plain, target: self, action: #selector(phoneCallActionHandler))
        
        navigationItem.rightBarButtonItems = [audioCallButton, videoCallButton]
        navigationItem.leftItemsSupplementBackButton = true
        
        if viewModel.room?.type == .privateRoom {
            friendInfoView.change(avatarUrl: viewModel.friendUser?.getAvatarUrl(), name: viewModel.friendUser?.getDisplayName(), lastSeen: "yesterday")
        } else {
            friendInfoView.change(avatarUrl: viewModel.room?.getAvatarUrl(),
                                  name: viewModel.room?.name,
                                  lastSeen: "today")
        }
        
        let vtest = UIBarButtonItem(customView: friendInfoView)
        navigationItem.leftBarButtonItem = vtest
    }
    
    @objc func videoCallActionHandler() {
    }
    
    @objc func phoneCallActionHandler() {
        
    }
}

// MARK: - swipe gestures on cells

extension CurrentChatViewController {
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let firstRight = UIContextualAction(style: .normal, title: "Details") { (action, view, completionHandler) in
            if let messageEntity = self.frc?.object(at: indexPath),
               let records = Message(messageEntity: messageEntity).records {
                self.viewModel.presentMessageDetails(records: records)
                completionHandler(true)
            }
        }
        firstRight.backgroundColor = .systemBlue
        return UISwipeActionsConfiguration(actions: [firstRight])
    }
    
}

// MARK: - Photo Video picker

extension CurrentChatViewController: PHPickerViewControllerDelegate {
    
    func presentLibraryPicker() {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        
        configuration.filter = .any(of: [.images, .livePhotos, .videos]) // TODO: check
        configuration.preferredAssetRepresentationMode = .current
        configuration.selectionLimit = 30
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        print("RESULTS COUNT: ", results.count)
        for result in results {
            
            if result.itemProvider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.image.identifier) { url, error in
                    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
                    guard let url = url,
                          let targetURL = documentsDirectory?.appendingPathComponent(url.lastPathComponent),
                          url.copyFileFromURL(to: targetURL) == true
                    else { return }
                    let thumbnail = targetURL.imageThumbnail()
                    let file = SelectedFile(fileType: .image, name: nil,
                                            fileUrl: targetURL, thumbnail: thumbnail)
                    self.viewModel.selectedFiles.value.append(file)
                }
            }
            
            if result.itemProvider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
                result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { url, error in
                    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
                    guard let url = url,
                          let targetURL = documentsDirectory?.appendingPathComponent(url.lastPathComponent),
                          url.copyFileFromURL(to: targetURL) == true
                    else { return }
                    let thumb = url.videoThumbnail()
                    let file  = SelectedFile(fileType: .movie, name: "video",
                                             fileUrl: targetURL, thumbnail: thumb)
                    self.viewModel.selectedFiles.value.append(file)
                }
            }
        }
    }
}

// MARK: - File picker

extension CurrentChatViewController: UIDocumentPickerDelegate {
    func presentFilePicker() {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.item], asCopy: true)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = true
        present(documentPicker, animated: true, completion: nil)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        controller.dismiss(animated: true)
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        
        for url in urls {
            guard let targetURL = documentsDirectory?.appendingPathComponent(url.lastPathComponent),
                  url.copyFileFromURL(to: targetURL) == true,
                  let resourceValues = try? url.resourceValues(forKeys: [.contentTypeKey, .nameKey]),
                  let fileName = resourceValues.name,
                  let type = resourceValues.contentType
            else { return }
            
            let file = SelectedFile(fileType: type, name: fileName,
                                    fileUrl: targetURL, thumbnail: type.thumbnail())
            self.viewModel.selectedFiles.value.append(file)
        }
    }
    
    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true)
    }
}
