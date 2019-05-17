//
//  UIBezierPath+Extension.swift
//  IOSARSample
//
//  Created by Viethai Pham on 17/5/19.
//  Copyright © 2019 swiften. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit

extension UIBezierPath {
  public static func arrow(from start: CGPoint,
                           to end: CGPoint,
                           tailWidth: CGFloat,
                           headWidth: CGFloat,
                           headLength: CGFloat) -> UIBezierPath {
    let length = hypot(end.x - start.x, end.y - start.y)
    let tailLength = length - headLength
    
    let points: [CGPoint] = [
      CGPoint(x: 0, y: tailWidth / 2),
      CGPoint(x: tailLength, y: tailWidth / 2),
      CGPoint(x: tailLength, y: headWidth / 2),
      CGPoint(x: length, y: 0),
      CGPoint(x: tailLength, y: -headWidth / 2),
      CGPoint(x: tailLength, y: -tailWidth / 2),
      CGPoint(x: 0, y: -tailWidth / 2)
    ]
    
    let cosine = (end.x - start.x) / length
    let sine = (end.y - start.y) / length

    let transform = CGAffineTransform(a: cosine,
                                      b: sine,
                                      c: -sine,
                                      d: cosine,
                                      tx: start.x,
                                      ty: start.y)
    
    let path = CGMutablePath()
    path.addLines(between: points, transform: transform)
    path.closeSubpath()
    return UIBezierPath(cgPath: path)
  }
  
  public static func arrow(fromTip tipPoint: CGPoint,
                           length: CGFloat,
                           radianFromTip radian: CGFloat,
                           tailWidth: CGFloat,
                           headWidth: CGFloat,
                           headLength: CGFloat) -> UIBezierPath {
    let endX = length * cos(radian) + tipPoint.x
    let endY = length * sin(radian) + tipPoint.y
    let endPoint = CGPoint(x: endX, y: endY)

    return UIBezierPath.arrow(from: endPoint,
                              to: tipPoint,
                              tailWidth: tailWidth,
                              headWidth: headWidth,
                              headLength: headLength)
  }
}
