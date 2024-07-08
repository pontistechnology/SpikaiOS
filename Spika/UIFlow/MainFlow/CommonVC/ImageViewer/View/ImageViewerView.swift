//
//  ImageViewerView.swift
//  Spika
//
//  Created by Nikola Barbarić on 17.11.2022..
//

import UIKit

class ImageViewerView: UIView, UIScrollViewDelegate {
    
    private let scrollView = UIScrollView()
    let imageView = UIImageView()
    let optionsLabel = RoundedLabel("Options", cornerRadius: 10)
    let infoLabel = CustomLabel(text: "Sender info", textColor: .textPrimary, alignment: .center)
    
    init() {
        super.init(frame: .zero)
        setupView()
        scrollView.delegate = self
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(recognizer:)))
        tapRecognizer.numberOfTapsRequired = 2
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapRecognizer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
    
    func setInfoLabel(text: String) {
        infoLabel.setText(text: text)
    }
}

extension ImageViewerView: BaseView {
    func addSubviews() {
        addSubview(scrollView)
        addSubview(optionsLabel)
        addSubview(infoLabel)
        scrollView.addSubview(imageView)
    }
    
    func styleSubviews() {
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 5
        imageView.contentMode = .scaleAspectFit
        infoLabel.numberOfLines = 0
    }
    
    func positionSubviews() {
        infoLabel.centerXToSuperview()
        infoLabel.anchor(top: topAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 0))

        scrollView.anchor(top: infoLabel.bottomAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: .init(top: 6, left: 0, bottom: 0, right: 0))
        optionsLabel.anchor(bottom: bottomAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0))
        optionsLabel.centerXToSuperview()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        imageView.heightAnchor.constraint(equalTo: scrollView.heightAnchor).isActive = true
    }
    
    @objc private func handleDoubleTap(recognizer: UITapGestureRecognizer) {
        let scale = min(scrollView.zoomScale * 2, scrollView.maximumZoomScale)

        if scale != scrollView.zoomScale {
            let point = recognizer.location(in: imageView)

            let scrollSize = scrollView.frame.size
            let size = CGSize(width: scrollSize.width / scrollView.maximumZoomScale,
                              height: scrollSize.height / scrollView.maximumZoomScale)
            let origin = CGPoint(x: point.x - size.width / 2,
                                 y: point.y - size.height / 2)
            scrollView.zoom(to:CGRect(origin: origin, size: size), animated: true)
        } else {
            scrollView.zoom(to: zoomRectForScale(scale: scrollView.maximumZoomScale, center: recognizer.location(in: imageView)), animated: true)
        }
    }

    private func zoomRectForScale(scale: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        zoomRect.size.height = imageView.frame.size.height / scale
        zoomRect.size.width  = imageView.frame.size.width  / scale
        let newCenter = scrollView.convert(center, from: imageView)
        zoomRect.origin.x = newCenter.x - (zoomRect.size.width / 2.0)
        zoomRect.origin.y = newCenter.y - (zoomRect.size.height / 2.0)
        return zoomRect
    }
    
    func setImage(link: URL?, thumbLink: URL?) {
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(with: thumbLink, placeholder: UIImage(resource: .unknownFileThumbnail)) { [weak self] _ in
            self?.imageView.kf.setImage(with: link)
        }
    }
    
    func setImage(path: String) {
        imageView.image = UIImage(contentsOfFile: path)
    }
    
}
