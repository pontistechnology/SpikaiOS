//
//  CircularProgressBar.swift
//  Spika
//
//  Created by Nikola Barbarić on 11.03.2022..
//

import Foundation
import UIKit

class CircularProgressBar: UIView, BaseView {
    
    let shapeLayer = CAShapeLayer()
    private let width = 35.0
    
    init() {
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        
    }
    
    func styleSubviews() {
        backgroundColor = .systemRed
        print("center prije: ", center)
        let circularPath = UIBezierPath(arcCenter: CGPoint(x: width/2, y: width/2),
                                        radius: 12,
                                        startAngle: -.pi/2,
                                        endAngle: 2 * CGFloat.pi - .pi/2,
                                        clockwise: true)
        
//        let backgroundLayer = CAShapeLayer()
//        backgroundLayer.path = circularPath.cgPath
//        backgroundLayer.strokeColor = UIColor.textTertiary.cgColor
//        backgroundLayer.fillColor = UIColor.clear.cgColor
//        backgroundLayer.lineWidth = 10
//        layer.addSublayer(backgroundLayer)
        
        shapeLayer.path = circularPath.cgPath
        shapeLayer.strokeColor = UIColor.primaryColor.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 5
        shapeLayer.strokeEnd = 0.1
        shapeLayer.lineCap = .round
        layer.addSublayer(shapeLayer)
    }
    
    func positionSubviews() {
        constrainWidth(width)
        constrainHeight(width)
        print("center kasnije: ", center)
//        animateProgress()
    }
    
    func animateProgress() {
        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        basicAnimation.toValue = 1
        basicAnimation.duration = 2
        basicAnimation.fillMode = .forwards
        basicAnimation.isRemovedOnCompletion = false
        shapeLayer.add(basicAnimation, forKey: Constants.CABasicAnimations.circularProgressStroke)
    }
    
    func setProgress(to value: CGFloat) {
        shapeLayer.strokeEnd = value
    }
}
