//
//  ImageViewerViewController.swift
//  Spika
//
//  Created by Nikola Barbarić on 17.11.2022..
//

import Foundation

class ImageViewerViewController: BaseViewController {
    
    private let imageViewerView = ImageViewerView()
    var viewModel: ImageViewerViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView(imageViewerView)
        if let localURL = viewModel.getLocalURL() {
            imageViewerView.setImage(path: localURL.path)
        } else {
            imageViewerView.setImage(link: viewModel.getOnlineURL(), thumbLink: viewModel.getThumbOnlineURL())
        }
    }
}
