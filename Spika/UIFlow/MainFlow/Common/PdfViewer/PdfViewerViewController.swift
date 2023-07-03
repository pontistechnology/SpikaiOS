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
    private let saveLabel = CustomLabel(text: "Save")
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
        saveLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, trailing: view.safeAreaLayoutGuide.trailingAnchor, padding: UIEdgeInsets(top: 4, left: 0, bottom: 0, right: 4))
        saveLabel.backgroundColor = .primaryColor
        saveLabel.layer.cornerRadius = 4
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
            
            let vv = UIActivityViewController(activityItems: [self.url], applicationActivities: nil)
            self.present(vv, animated: true)
        }.store(in: &subscriptions)
    }
}

