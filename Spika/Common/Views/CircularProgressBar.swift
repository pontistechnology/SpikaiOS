//
//  CircularProgressBar.swift
//  Spika
//
//  Created by Nikola Barbarić on 11.03.2022..
//

import Foundation
import UIKit

class CircularProgressBar: UIView, BaseView {
    
    private let shapeLayer = CAShapeLayer()
    private let width: CGFloat
    private let lineWidth: CGFloat = 5.0
    private let backgroundView = UIView()
    private let containerView  = UIView()
    private let label = CustomLabel(text: "44%")
    
    init(spinnerWidth: CGFloat) {
        self.width = spinnerWidth
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        addSubview(backgroundView)
        backgroundView.addSubview(containerView)
        containerView.addSubview(label)
    }
    
    func styleSubviews() {
        backgroundView.backgroundColor = .darkGray.withAlphaComponent(0.5)
        containerView.backgroundColor = .clear
        
        let circularPath = UIBezierPath(arcCenter: CGPoint(x: width/2, y: width/2),
                                        radius: width/2 - lineWidth/2,
                                        startAngle: -.pi/2,
                                        endAngle: 2 * CGFloat.pi - .pi/2,
                                        clockwise: true)
                
        shapeLayer.path = circularPath.cgPath
        shapeLayer.strokeColor = UIColor.primaryColor.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = lineWidth
        shapeLayer.strokeEnd = 0
        shapeLayer.lineCap = .round
        containerView.layer.addSublayer(shapeLayer)
    }
    
    func positionSubviews() {
        backgroundView.fillSuperview()
        containerView.constrainWidth(width)
        containerView.constrainHeight(width)
        containerView.centerInSuperview()
        label.centerXToSuperview()
        label.centerYToSuperview(offset: 20)
    }
    
    func setProgress(to value: CGFloat) {
        containerView.layer.removeAllAnimations()
        shapeLayer.strokeEnd = value
        label.text = "\(value * 100) %"
    }
    
    func startSpinning(with text: String? = nil) {
        label.text = text
        shapeLayer.strokeEnd = 0.75
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotationAnimation.fromValue = 0.0
        rotationAnimation.toValue = Double.pi * 2
        rotationAnimation.duration = 2
        rotationAnimation.repeatCount = .infinity
        containerView.layer.add(rotationAnimation, forKey: nil)
    }
}
