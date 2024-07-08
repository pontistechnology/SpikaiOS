//
//  ImageViewerViewModel.swift
//  Spika
//
//  Created by Nikola Barbarić on 17.11.2022..
//

import Foundation
import UIKit

class ImageViewerViewModel: BaseViewModel {
    var message: Message!
    var senderName: String!
    
    var info: String {
        senderName.appending("\n").appending(message.createdAt.convert(to: .ddMMyyyyHHmm))
    }
    
    func getLocalURL() -> URL? {
        guard message.fromUserId == myUserId,
              let localId = message.localId,
              let url = repository.getFile(name: localId)
        else { return nil }
        return url
    }
    
    func getOnlineURL() -> URL? {
        guard let url = message.body?.file?.id?.fullFilePathFromId()
        else { return nil }
        return url        
    }
    
    func getThumbOnlineURL() -> URL? {
        guard let url = message.body?.thumb?.id?.fullFilePathFromId()
        else { return nil }
        return url
    }
    
    func presentShareSheet(image: UIImage) {
        let temporaryFolder = FileManager.default.temporaryDirectory
        let fileName = message.body?.file?.fileName ?? "unknown.jpg"
        let temporaryFileURL = temporaryFolder.appendingPathComponent(fileName)
        
        guard (try? image.jpgOrPngData(fileName: fileName)?.write(to: temporaryFileURL)) != nil
        else {
            showError("Something went wrong.")
            return
        }
        let c = ShareSourceProvider(shareType: .sharePhoto(url: temporaryFileURL))
        getAppCoordinator()?.presentShareScreen(source: c)
    }
}
