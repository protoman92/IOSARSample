//
//  Calculation.swift
//  IOSARSample
//
//  Created by Viethai Pham on 18/5/19.
//  Copyright © 2019 swiften. All rights reserved.
//

public final class Calculation {
  public static func degreeToRadian<B>(_ degree: B) -> B where B: BinaryFloatingPoint {
    return degree * B.pi / 180
  }
}
