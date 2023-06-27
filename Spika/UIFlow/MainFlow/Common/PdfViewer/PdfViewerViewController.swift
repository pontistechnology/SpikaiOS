//
//  PdfViewerViewController.swift
//  Spika
//
//  Created by Nikola Barbarić on 27.06.2023..
//

import Foundation
import PDFKit

class PdfViewerViewController: BaseViewController {
    let pdfView = PDFView()
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
        pdfView.fillSuperview()
//        pdfView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        DispatchQueue.global().async { [weak self] in
            // This method should not be called on the main thread as it may lead to UI unresponsiveness.
            guard let url = self?.url else { return }
            if let document = PDFDocument(url: url) {
                DispatchQueue.main.async { [weak self] in
                    self?.pdfView.document = document
                }
            }
        }
    }
}

