//
//  RubberCell.swift
//  RubberMenu
//
//  Created by HIROTOSHI KAWAUCHI on 2017/04/09.
//  Copyright © 2017年 HIROTOSHI KAWAUCHI. All rights reserved.
//

import UIKit

class RubberCell: UICollectionViewCell {
    
    var heightNew: CGFloat = 0.0
    
    func setNewHeight(_ h: CGFloat) {
        if h > 35 {
            heightNew = 35
        } else if h < -35 {
            heightNew = -35
        } else {
            heightNew = h
        }
        layer.mask = mask()
    }
    
    func pathWithHeight(_ height: CGFloat) -> UIBezierPath {
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 0.0, y: 35.0)) // 起点
        
        bezierPath.addCurve(to: CGPoint(x: frame.size.width,y: 35.0), // 終着点
                            controlPoint1: CGPoint(x: frame.size.width/2, y: 35+height),
                            controlPoint2: CGPoint(x: frame.size.width, y: 35))
        bezierPath.addLine(to: CGPoint(x: frame.size.width, y: frame.size.height))
        bezierPath.addLine(to: CGPoint(x: 0.0, y: frame.size.height))
        bezierPath.addLine(to: CGPoint(x: 0.0, y: 35.0))
        return bezierPath
    }
    
    func mask() -> CAShapeLayer {
        let myClippingPath = pathWithHeight(heightNew)
        let mask = CAShapeLayer()
        mask.path = myClippingPath.cgPath
        return mask
    }
    
}
