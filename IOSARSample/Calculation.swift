//
//  Calculation.swift
//  IOSARSample
//
//  Created by Viethai Pham on 18/5/19.
//  Copyright © 2019 swiften. All rights reserved.
//

import CoreGraphics
import GLKit

public final class Calculation {
  public static func degreeToRadian<B>(_ degree: B) -> B where B: BinaryFloatingPoint {
    return degree * B.pi / 180
  }
  
  public static func radianToDegree<B>(_ radian: B) -> B where B: BinaryFloatingPoint {
    return radian * 180 / B.pi
  }
  
  public static func bearingRadian(start: Coordinate, end: Coordinate) -> Double {
    let lat1 = degreeToRadian(start.latitude)
    let lon1 = degreeToRadian(start.longitude)
    let lat2 = degreeToRadian(end.latitude)
    let lon2 = degreeToRadian(end.longitude)
    let dLon = lon2 - lon1
    let y = sin(dLon) * cos(lat2)
    let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
    var radian = atan2(y, x)
    if radian < 0 { radian += Double.pi * 2 }
    return radian
  }
  
  public static func bearingDegree(start: Coordinate, end: Coordinate) -> Double {
    return radianToDegree(bearingRadian(start: start, end: end))
  }
}
