//
//  ImageViewerViewModel.swift
//  Spika
//
//  Created by Nikola Barbarić on 17.11.2022..
//

import Foundation

class ImageViewerViewModel: BaseViewModel {
    var message: Message!
    
    func getLocalURL() -> URL? {
        guard message.fromUserId == getMyUserId(),
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
}
