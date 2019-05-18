//
//  Data.swift
//  IOSARSample
//
//  Created by Viethai Pham on 18/5/19.
//  Copyright © 2019 swiften. All rights reserved.
//

import CoreLocation

public struct Coordinate {
  public let latitude: Double
  public let longitude: Double
  
  public init(latitude: Double, longitude: Double) {
    self.latitude = latitude
    self.longitude = longitude
  }
  
  public init(coordinate: CLLocationCoordinate2D) {
    self.init(latitude: coordinate.latitude, longitude: coordinate.longitude)
  }
  
  public init(location: CLLocation) {
    self.init(coordinate: location.coordinate)
  }
  
  public func with(latitude: Double) -> Coordinate {
    return Coordinate(latitude: latitude, longitude: self.longitude)
  }
  
  public func with(longitude: Double) -> Coordinate {
    return Coordinate(latitude: self.latitude, longitude: longitude)
  }
}

public struct Settings {
  public private(set) var coordinate: Coordinate
  
  public init(coordinate: Coordinate) {
    self.coordinate = coordinate
  }
  
  public init() {
    self.init(coordinate: Coordinate(latitude: 0, longitude: 0))
  }
  
  private init(_ settings: Settings) {
    self.coordinate = settings.coordinate
  }
  
  public func with(coordinate: Coordinate) -> Settings {
    var copy = Settings(self)
    copy.coordinate = coordinate
    return copy
  }
  
  public func with(latitude: Double) -> Settings {
    return self.with(coordinate: self.coordinate.with(latitude: latitude))
  }
  
  public func with(longitude: Double) -> Settings {
    return self.with(coordinate: self.coordinate.with(longitude: longitude))
  }
}
