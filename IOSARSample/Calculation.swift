//
//  Calculation.swift
//  IOSARSample
//
//  Created by Viethai Pham on 18/5/19.
//  Copyright © 2019 swiften. All rights reserved.
//

import CoreGraphics

public final class Calculation {
  public static func degreeToRadian<B>(_ degree: B) -> B where B: BinaryFloatingPoint {
    return degree * B.pi / 180
  }
  
  public static func radianToDegree<B>(_ radian: B) -> B where B: BinaryFloatingPoint {
    return radian * 180 / B.pi
  }
  
  public static func haversineKM(start: Coordinate, end: Coordinate) -> Double {
    let earthRadius = 6378.137
    let lat1rad = degreeToRadian(start.latitude)
    let lon1rad = degreeToRadian(start.longitude)
    let lat2rad = degreeToRadian(end.latitude)
    let lon2rad = degreeToRadian(end.longitude)
    let dLat = lat2rad - lat1rad
    let dLon = lon2rad - lon1rad
    let a = sin(dLat / 2) * sin(dLat / 2) + sin(dLon / 2) * sin(dLon / 2) * cos(lat1rad) * cos(lat2rad)
    let c = 2 * asin(sqrt(a))
    return earthRadius * c
  }
  
  public static func haversineM(start: Coordinate, end: Coordinate) -> Double {
    return haversineKM(start: start, end: end) * 1000
  }
  
  public static func bearingRadian(start: Coordinate, end: Coordinate) -> Double {
    let lat1 = degreeToRadian(start.latitude)
    let lon1 = degreeToRadian(start.longitude)
    let lat2 = degreeToRadian(end.latitude)
    let lon2 = degreeToRadian(end.longitude)
    let dLon = lon2 - lon1
    let y = sin(dLon) * cos(lat2)
    let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
    return atan2(y, x)
  }
  
  public static func bearingDegree(start: Coordinate, end: Coordinate) -> Double {
    let radian = bearingRadian(start: start, end: end)
    var degree = radianToDegree(radian)
    if degree < 0 { degree += 360 }
    return degree
  }
}
