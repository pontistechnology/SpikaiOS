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
    private let optionsLabel = RoundedLabel("Options", cornerRadius: 10)
    let url: URL
    let shareType: ShareActivityType
    private let fileName: String
    
    init(shareType: ShareActivityType) {
        self.shareType = shareType
        switch shareType {
        case .sharePdf(let temporaryURL, let file):
            self.url = temporaryURL
            self.fileName = file.fileName ?? ""
        case .sharePhoto(let image):
            self.url = URL(string: "")!
            self.fileName = ""
        }
        super.init()
        title = fileName
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(pdfView)
        view.addSubview(optionsLabel)
        pdfView.fillSuperview()
        optionsLabel.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0))
        optionsLabel.centerXToSuperview()
        optionsLabel.hide()
        setupBindings()
//        pdfView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        DispatchQueue.global().async { [weak self] in
            // This method should not be called on the main thread as it may lead to UI unresponsiveness.
            guard let url = self?.url else { return }
            if let document = PDFDocument(url: url) {
                DispatchQueue.main.async { [weak self] in
                    self?.pdfView.document = document
                    self?.pdfView.autoScales = true
                    self?.optionsLabel.unhide()
                }
            }
        }
    }
    
    func setupBindings() {
        optionsLabel.tap().sink { [weak self] _ in
            guard let self else { return }
            let temporaryFolder = FileManager.default.temporaryDirectory
            let fileName = shareType.fileName
            let temporaryFileURL = temporaryFolder.appendingPathComponent(fileName)
            
            try? pdfView.document?.dataRepresentation()?.write(to: temporaryFileURL)
            let activityViewController = UIActivityViewController(activityItems: [temporaryFileURL], applicationActivities: nil)
            navigationController?.present(activityViewController, animated: true)
        }.store(in: &subscriptions)
    }
}
