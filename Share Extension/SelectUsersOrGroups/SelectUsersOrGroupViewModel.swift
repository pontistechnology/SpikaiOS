//
//  SelectUsersOrGroupViewModel.swift
//  Share Extension
//
//  Created by Nikola Barbarić on 23.08.2024..
//

import Foundation
import UniformTypeIdentifiers
import CryptoKit

class SelectUsersOrGroupsViewModel: ObservableObject {
    var hideUserIds: [Int64] = []
    @Published var searchTerm = ""
    @Published var selectedUsersAndGroups: [SelectedUserOrGroup] = []
    @Published var isUsersSelected = true
    @Published var statusUpdate1 = "Preparing..."
    @Published var showLoading = false
    var numberOfSentFiles = 0
    let networkManager = NetworkManager2()
    var itemProviders: [NSItemProvider]
    var extensionContext: NSExtensionContext?
    
    init(itemProviders: [NSItemProvider], extensionContext: NSExtensionContext?) {
        self.itemProviders = itemProviders
        self.extensionContext = extensionContext
    }
    
    let usersSortDescriptor = [
        NSSortDescriptor(key: "contactsName", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:))),
        NSSortDescriptor(key: #keyPath(UserEntity.displayName), ascending: true)]
    
    let roomsSortDescriptor = [
        NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:))),
        NSSortDescriptor(key: #keyPath(RoomEntity.lastMessageTimestamp), ascending: false)]
    
    var usersPredicate: NSPredicate? {
        searchTerm.isEmpty
        ? NSPredicate(format: "NOT (id IN %@)", hideUserIds)
        : NSPredicate(format: "(contactsName CONTAINS[c] '\(searchTerm)' OR telephoneNumber CONTAINS[c] '\(searchTerm)') AND NOT (id IN %@)", hideUserIds)
    }
    
    var roomsPredicate: NSPredicate? {
        searchTerm.isEmpty
        ? NSPredicate(format: "type == '\(RoomType.groupRoom.rawValue)'")
        : NSPredicate(format: "name CONTAINS[c] '\(searchTerm)'")
    }
    
    func copyFileToTempFolder(url: URL) -> URL {
        let temporaryFolder = FileManager.default.temporaryDirectory
        let fileName = url.lastPathComponent
        let temporaryFileURL = temporaryFolder.appendingPathComponent(fileName)
        do {
            if FileManager.default.fileExists(atPath: temporaryFileURL.path) {
                try FileManager.default.removeItem(at: temporaryFileURL)
            }
            try FileManager.default.copyItem(at: url, to: temporaryFileURL)
        } catch {
            print("DEBUGPRINT: file copy failed", error)
        }
        return temporaryFileURL
    }
    
    func uploadAndSend(url: URL, isVideo: Bool) {
        Task {
            // TODO: - check
            DispatchQueue.main.async {
                self.statusUpdate1 = "Uploading"
            }
            guard let id = await self.uploadFile(url: url, mimeType: isVideo ? "video/mp4" : "image/*")
            else { return }
            await self.share(fileId: id, thumbId: id, isVideo: isVideo)
            self.numberOfSentFiles += 1
            DispatchQueue.main.async {
                self.statusUpdate1 = "Sending \(self.numberOfSentFiles) / \(self.itemProviders.count)"
                if self.numberOfSentFiles == self.itemProviders.count {
                    self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
                }
            }
        }
    }
    
    func sendVideo(videoId: Int64, thumbId: Int64) async {
        await share(fileId: videoId, thumbId: thumbId, isVideo: true)
        self.numberOfSentFiles += 1
        DispatchQueue.main.async {
            self.statusUpdate1 = "Sending \(self.numberOfSentFiles) / \(self.itemProviders.count)"
            if self.numberOfSentFiles == self.itemProviders.count {
                self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
            }
        }
    }
    
    
    func doneButtont() {
        showLoading = true
        for provider in itemProviders {
            if provider
                .hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                provider.loadFileRepresentation(forTypeIdentifier: UTType.image.identifier) { [weak self] url, error in
                    guard let url else { return }
                    guard let self else { return }
                    let temporaryFileURL = copyFileToTempFolder(url: url)
                    uploadAndSend(url: temporaryFileURL, isVideo: false)
                }
            }
            
            if provider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
                provider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { [weak self] url, error in
                    guard let self else { return }
                    guard let url else { return }
                    let tempVideoUrl = copyFileToTempFolder(url: url)
                    guard let tempThumbURL = saveThumbToFile(videoUrl: tempVideoUrl) else { return }
                    Task { [weak self] in
                        guard let self else { return }
                        guard let thumbId = await uploadFile(url: tempThumbURL, mimeType: "image/*") else {
                            changeStatus(to: "Can't create thumb. Open the app.")
                            return
                        }
                        changeStatus(to: "Compressing video")
                        guard let compressedVideoUrl = await tempVideoUrl.compressAsMP4(name: "compressedVideo".appending(UUID().uuidString))
                        else {
                            changeStatus(to: "Can't compress video. Open the app.")
                            return
                        }
                        changeStatus(to: "Uploading video")
                        guard let videoId = await uploadFile(url: compressedVideoUrl, mimeType: "video/mp4") else {
                            changeStatus(to: "Can't upload video. Open the app.")
                            return
                        }
                        changeStatus(to: "Sending video")
                        await sendVideo(videoId: videoId, thumbId: thumbId)
                        
                        
                    }
                    
                }
            }
        }
    }
    
   
    func changeStatus(to newString: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            statusUpdate1 = newString
        }
    }
    
    func saveThumbToFile(videoUrl: URL) -> URL? {
        let data = videoUrl.videoThumbnail()?.jpegData(compressionQuality: 1)
        let tempDirectory = FileManager.default.temporaryDirectory
        let targetURL = tempDirectory.appendingPathComponent("thumbOf".appending(videoUrl.lastPathComponent))
        do {
            if FileManager.default.fileExists(atPath: targetURL.path) {
                try FileManager.default.removeItem(at: targetURL)
            }
            try data?.write(to: targetURL)
            return targetURL
        } catch(let err) {
            print(err.localizedDescription)
            return nil
        }
    }
    
}

// MARK: - NETWORK CALLS

extension SelectUsersOrGroupsViewModel {
    func verifyUpload(total: Int, size: Int, mimeType: String, fileName: String, clientId: String, fileHash: String, type: String, relationId: Int, metaData: MetaData) async -> Int64? {
        let r = VerifyFileRequestModel(total: total, size: size, mimeType: mimeType, fileName: fileName, type: type, fileHash: fileHash, relationId: relationId, clientId: clientId, metaData: metaData)
        let resources = Resources(path: Constants.Endpoints.verifyFile,
                                  requestType: .POST,
                                  bodyParameters: r,
                                  httpHeaderFields: nil)
        let response: VerifyFileResponseModel? = await networkManager.performRequest(resources: resources)
        return response?.data?.file?.id
    }
    
    func uploadChunk(chunk: String, offset: Int, clientId: String) async -> Int {
        let r = UploadChunkRequestModel(chunk: chunk, offset: offset, clientId: clientId)
        let resources = Resources(path: Constants.Endpoints.uploadFiles,
                                  requestType: .POST,
                                  bodyParameters: r,
                                  httpHeaderFields: nil)
        let response: UploadChunkResponseModel? = await networkManager.performRequest(resources: resources)
        return response?.data?.uploadedChunks?.count ?? 0
    }
    
    func uploadFile(url: URL, mimeType: String) async -> Int64? {
        let chunkSize: Int = 1024 * 1024 // TODO: - determine best
        let clientId = UUID().uuidString
        var hasher = SHA256()
        var hash: String?
        guard FileManager.default.fileExists(atPath: url.path),
              let outputFileHandle = try? FileHandle(forReadingFrom: url),
              let resources = try? url.resourceValues(forKeys:[.fileSizeKey, .nameKey]),
              let fileSize = resources.fileSize
        else {
            print("DEBUGPRINT: upload file error, file is not at given url")
            return nil
        }
        let fileName = url.lastPathComponent
        let totalChunks = fileSize / chunkSize + (fileSize % chunkSize != 0 ? 1 : 0)
        print("DEBUGPRINT: totalChunks: ", totalChunks, "filesize: ", fileSize)
        var chunk = try? outputFileHandle.read(upToCount: chunkSize)
        var chunkOffset = 0
        while (chunk != nil) {
            guard let safeChunk = chunk else { break }
            hasher.update(data: safeChunk)
            hash = hasher.finalize().compactMap { String(format: "%02x", $0)}.joined()
            
            let numberOfUploadedChunks = await uploadChunk(chunk: safeChunk.base64EncodedString(),
                                                           offset: chunkOffset,
                                                           clientId: clientId)
            chunk = try? outputFileHandle.read(upToCount: chunkSize)
            chunkOffset += 1
            //            statusUpdate2 = "Uploading \(Float(numberOfUploadedChunks)/Float(totalChunks)*100) %"
            
            if numberOfUploadedChunks == totalChunks {
                guard let hash = hash else { return nil }
                try? outputFileHandle.close()
                return await verifyUpload(total: totalChunks, size: fileSize, mimeType: mimeType, fileName: fileName, clientId: clientId, fileHash: hash, type: hash, relationId: 1, metaData: MetaData(width: 40, height: 40, duration: 0))
            }
        }
        return nil
    }
    
    func share(fileId: Int64, thumbId: Int64, isVideo: Bool) async {
        let r = ShareMessageRequestModel(roomIds: selectedUsersAndGroups.onlyRoomIds,
                                         messages: [ShareMessageaaa(type: isVideo ? MessageType.video.rawValue : MessageType.image.rawValue, body: RequestMessageBody(text: nil, fileId: fileId, thumbId: thumbId))], userIds: selectedUsersAndGroups.onlyUserIds)
        let resources = Resources(path: Constants.Endpoints.share, requestType: .POST, bodyParameters: r)
        let response: ShareMessageResponseModel? = await networkManager.performRequest(resources: resources)
        await saveMessages(messages: response?.messages ?? [], rooms: response?.newRooms ?? [])
    }
    
    func saveMessages(messages: [Message], rooms: [Room]) async {
        try? await CoreDataStack().persistentContainer.performBackgroundTask { context in
            
            for room in rooms {
                let roomEntity = RoomEntity(room: room, context: context)
                for roomUser in room.users {
                    _ = RoomUserEntity(roomUser: roomUser, insertInto: context)
                    _ = UserEntity(user: roomUser.user, context: context)
                }
                // this is because mute or unmute will update room and reset it to zero
                // TODO: - maybe add functions for update pin, mute
                roomEntity.lastMessageTimestamp = messages.first?.createdAt ?? 0
            }
            do {
                if context.hasChanges {
                    try context.save()
                }
            } catch {
                NSLog("Core Data Error: saving rooms: \(error.localizedDescription)")
            }
            
            
            var uniqueRoomIds = Set<Int64>()
            for message in messages {
                _ = MessageEntity(message: message, context: context)
                
                if let file = message.body?.file,
                   let localId = message.localId {
                    _ = FileEntity(file: file, localId: localId, context: context)
                }
                
                if let thumb = message.body?.thumb,
                   let localId = message.localId {
                    _ = FileEntity(file: thumb, localId: localId.appending("thumb"), context: context)
                }
                
                if let records = message.records {
                    records.forEach { record in
                        _ = MessageRecordEntity(record: record, context: context)
                    }
                }
                uniqueRoomIds.insert(message.roomId)
            }
            
            
            do {
                if context.hasChanges {
                    try context.save()
                }
            } catch {
                    NSLog("Core Data Error: saving messages: \(error.localizedDescription)")
                }
            }
        }
    }
