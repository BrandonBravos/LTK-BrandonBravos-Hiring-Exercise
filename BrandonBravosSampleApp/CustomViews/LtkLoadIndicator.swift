//
//  LtkLoadIndicator.swift
//  BrandonBravosSampleApp
//
//  Created by Brandon Bravos on 12/7/22.
//

import UIKit

/// a view for showing a custom loading animation
class LtkLoadIndicator: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// pauses and hides the view
    public func pause(){
        let pausedTime = layer.convertTime(CACurrentMediaTime(), from: nil)
         layer.speed = 0.0
         layer.timeOffset = pausedTime
         alpha = 0
    }
    
    
    // unhides the view and resumes animation
    func resumeAnimation(){
        let pausedTime = layer.timeOffset
        layer.speed = 1.0
        layer.timeOffset = 0.0
        layer.beginTime = 0.0
        let timeSincePause = layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        layer.beginTime = timeSincePause
        
        alpha = 1
    }
    
    override func layoutSubviews() {
        let heartLayer = CALayer()
        heartLayer.contents = UIImage(named: "ltk_load_0")?.cgImage
        heartLayer.frame = bounds
        layer.addSublayer(heartLayer)
        
        let circleLayer = CALayer()
        circleLayer.contents = UIImage(named: "ltk_load_1")?.cgImage
        circleLayer.frame = bounds
        layer.addSublayer(circleLayer)
        

        let spinAnimation = CASpringAnimation(keyPath: #keyPath(CALayer.transform))
        spinAnimation.fromValue = 0
        spinAnimation.valueFunction = CAValueFunction(name: CAValueFunctionName.rotateZ)
        spinAnimation.timingFunction = CAMediaTimingFunction(name: .linear)
        spinAnimation.duration = 0.2
        spinAnimation.repeatCount = 100
        spinAnimation.toValue = CGFloat.pi

  
        
        //Apply all animations to sublayer
        CATransaction.begin()
        circleLayer.add(spinAnimation, forKey: #keyPath(CALayer.cornerRadius))
        CATransaction.commit()

    }
}
