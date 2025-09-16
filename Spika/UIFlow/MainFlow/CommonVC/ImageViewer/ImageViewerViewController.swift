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
        imageViewerView.setInfoLabel(text: viewModel.info)
        imageViewerView.optionsLabel.hide()
        if let localURL = viewModel.getLocalURL() {
            imageViewerView.setImage(path: localURL.path)
        } else {
            imageViewerView.setImage(link: viewModel.getOnlineURL(),
                                     thumbLink: viewModel.getThumbOnlineURL())
        }
        imageViewerView.optionsLabel.unhide()
        
    }
    
    func setupBindings() {
        imageViewerView.optionsLabel.tap().receive(on: DispatchQueue.main).sink { [weak self] _ in
            guard let self,
                  let image = imageViewerView.imageView.image
            else { return }
            viewModel.presentShareSheet(image: image)
        }.store(in: &subscriptions)
    }
}
