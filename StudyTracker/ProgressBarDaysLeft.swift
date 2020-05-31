//
//  ProgressBarDaysLeft.swift
//  StudyTracker
//
//  Created by Antanas Bruzga on 30/05/2020.
//  Copyright © 2020 Antanas Bruzga. All rights reserved.
//

import UIKit

class ProgressBarDaysLeft: UIView {
    

    @IBInspectable var startColor: UIColor = UIColor(red: 255/255, green: 255/255, blue: 102/255, alpha: 0.75)
    @IBInspectable var endColor: UIColor = UIColor(red: 255/255, green: 69/255, blue: 147/255, alpha: 0.75)

    
    // progress should be between 0 and 1
    var progress:CGFloat = 0
    
    override func draw(_ rect: CGRect) {
        
        // ______________________________________________
        // Displaying the gradient. References:
        // https://stackoverflow.com/questions/48235463/how-to-gradient-fill-custom-uiview-using-swift
        // from user Veture at https://stackoverflow.com/users/4441676/vetuka
        //_______________________________________________
        
        let context = UIGraphicsGetCurrentContext()!
        let colors = [startColor.cgColor, endColor.cgColor]
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let colorLocations: [CGFloat] = [0.0, 1.0]
        
        let gradient = CGGradient(colorsSpace: colorSpace,
                                  colors: colors as CFArray,
                                  locations: colorLocations)!
        
        let startPoint = CGPoint.zero
        let endPoint = CGPoint(x: bounds.width, y: bounds.height)
        context.drawLinearGradient(gradient,
                                   start: startPoint,
                                   end: endPoint,
                                   options: [CGGradientDrawingOptions(rawValue: 0)])
        // ____________________________________________
        
        
        
        
        // get size of self
        let widthMax = self.frame.size.width
        let heightMax = self.frame.size.width
        
        // convert progress to part of the size of self
        // because progress is 0 to 1, multiplying works:
        var progressXPosition = progress * widthMax
        //var progressXPosition = progress * 100 / widthMax
        print("MAX PROGRESS WIDTH \(widthMax)")
        print("X POS \(progressXPosition)")
        
        
        
        let progressLineWidth: CGFloat = 6.0
        
        // allows to show the line if it is already past deadline
        if (progressXPosition >= widthMax){
            progressXPosition = widthMax - progressLineWidth
        }
        // balances (progressLineWidth) bias to the  right in favour of (width/2) pixels delayed movement start
        else if (progressXPosition > progressLineWidth / 2){
            progressXPosition = progressXPosition - (progressLineWidth / 2)
        }
        
        let newRect  =   CGRect(x:progressXPosition,y:0,width:progressLineWidth, height:heightMax)
        let path = UIBezierPath(roundedRect: newRect, cornerRadius: 1.0)
        
        let progressColor: UIColor = UIColor(red: 255/255, green: 5/255, blue: 5/255, alpha: 0.55)
        progressColor.setFill()
     //   UIColor.red.setFill()
        path.fill()
        
        
        
        
    }
    
    override class func awakeFromNib() {
        
    }
    
    
    
    
}
