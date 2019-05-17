//
//  Data.swift
//  IOSARSample
//
//  Created by Viethai Pham on 18/5/19.
//  Copyright © 2019 swiften. All rights reserved.
//

public struct Settings {
  public private(set) var distanceInM: Double
  
  public init(distanceInM: Double) {
    self.distanceInM = distanceInM
  }
  
  public init() {
    self.init(distanceInM: 0)
  }
  
  private init(_ settings: Settings) {
    self.distanceInM = settings.distanceInM
  }
  
  public func with(distanceInM: Double) -> Settings {
    var copy = Settings(self)
    copy.distanceInM = distanceInM
    return copy
  }
}
