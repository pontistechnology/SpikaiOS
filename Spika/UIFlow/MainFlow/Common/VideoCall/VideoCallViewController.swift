//
//  VideoCallViewController.swift
//  Spika
//
//  Created by Nikola Barbarić on 16.02.2022..
//

import Foundation

class VideoCallViewController: BaseViewController {
    
    private let videoCallView: VideoCallView
    var viewModel: VideoCallViewModel!
    
    init(url: URL) {
        videoCallView = VideoCallView(url: url)
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView(videoCallView)
        setupBindings()
        navigationItem.title = "video Call"
    }
    
    func setupBindings(){
        
    }
}
