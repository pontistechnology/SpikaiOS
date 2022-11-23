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
        imageViewerView.setImage(link: viewModel.link)
    }
}
