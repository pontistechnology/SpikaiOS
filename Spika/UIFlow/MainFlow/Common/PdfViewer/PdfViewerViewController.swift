//
//  PdfViewerViewController.swift
//  Spika
//
//  Created by Nikola Barbarić on 27.06.2023..
//

import Foundation
import PDFKit

class PdfViewerViewController: BaseViewController {
    private let pdfView = PDFView()
    private let saveLabel = RoundedLabel("Download with Safari", cornerRadius: 10)
    let url: URL
    
    init(url: URL) {
        self.url = url
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(pdfView)
        view.addSubview(saveLabel)
        pdfView.fillSuperview()
        saveLabel.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0))
        saveLabel.centerXToSuperview()
        setupBindings()
//        pdfView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        DispatchQueue.global().async { [weak self] in
            // This method should not be called on the main thread as it may lead to UI unresponsiveness.
            guard let url = self?.url else { return }
            if let document = PDFDocument(url: url) {
                DispatchQueue.main.async { [weak self] in
                    self?.pdfView.document = document
                    self?.pdfView.autoScales = true    
                }
            }
        }
    }
    
    func setupBindings() {
        saveLabel.tap().sink { [weak self] _ in
            print("joj")
            guard let self else { return }
            if UIApplication.shared.canOpenURL(self.url) {
                UIApplication.shared.open(self.url)
            }
        }.store(in: &subscriptions)
    }
}

