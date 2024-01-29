//
//  ImageViewerViewController.swift
//  Spika
//
//  Created by Nikola Barbarić on 17.11.2022..
//

import Foundation
import UIKit

class ImageViewerViewController: BaseViewController {
    
    private let imageViewerView = ImageViewerView()
    var viewModel: ImageViewerViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView(imageViewerView)
        setupBindings()
        if let localURL = viewModel.getLocalURL() {
            imageViewerView.setImage(path: localURL.path)
        } else {
            imageViewerView.setImage(link: viewModel.getOnlineURL(),
                                     thumbLink: viewModel.getThumbOnlineURL())
        }
    }
    
    func setupBindings() {
        imageViewerView.saveLabel.tap().sink { [weak self] _ in
            guard let self,
                  let image = self.imageViewerView.imageView.image
            else { return }
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(viewModel.saveCompleted), nil)
        }.store(in: &subscriptions)
    }
}
