//
//  CircularProgressView.swift
//  StudyTracker
//
//  Created by Antanas Bruzga on 30/05/2020.
//  Copyright © 2020 Antanas Bruzga. All rights reserved.
//

import UIKit

//££££££££££££££££££££££££££££££££££
// View is adapted from https://github.com/leoiphonedev/CircularProgressView-Tutorial/blob/master/CircularProgressView-Tutorial/CircularProgressView.swift


class CircularProgressView: UIView {
    
    var progress: Float = 0
        
    private var progressLayer = CAShapeLayer()
    private var trackLayer = CAShapeLayer()
    
    var progressColour = UIColor.white {
        didSet  {
            progressLayer.strokeColor = progressColour.cgColor
        }
    }
    var trackColour = UIColor.white {
        didSet  {
            trackLayer.strokeColor = trackColour.cgColor
        }
    }
    
    override func draw(_ rect: CGRect) {
        createCircularPath()
    }
    
    fileprivate func createCircularPath(){
        self.backgroundColor = UIColor.clear
        self.layer.cornerRadius = self.frame.size.width/2
        
        let circlePath = UIBezierPath(
            arcCenter: CGPoint(x: frame.size.width/2, y: frame.size.height/2),
            radius: (frame.size.width-1.5)/2,
            startAngle: -0.5 * .pi,
            endAngle: CGFloat(1.5 * .pi),
            clockwise: true)
        
        trackLayer.path = circlePath.cgPath
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeColor = trackColour.cgColor
        trackLayer.lineWidth = 10.0
        trackLayer.strokeEnd = 1.0
        layer.addSublayer(trackLayer)
        
        progressLayer.path = circlePath.cgPath
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = progressColour.cgColor
        progressLayer.lineWidth = 10.0
        progressLayer.strokeEnd = CGFloat(progress)
        layer.addSublayer(progressLayer)
    }
    
    func setProgressWithAnimation(duration: TimeInterval, value: Float) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = duration
        animation.fromValue = 0
        animation.toValue = value
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        progressLayer.strokeEnd = CGFloat(value)
        progressLayer.add(animation, forKey: "animateprogress")
      
    }
    
}
//££££££££££££££££££££££££££££££££££
