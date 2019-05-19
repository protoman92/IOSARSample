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
  
  public func adding(latitude: Double) -> Coordinate {
    return self.with(latitude: self.latitude + latitude)
  }
  
  public func adding(longitude: Double) -> Coordinate {
    return self.with(longitude: self.longitude + longitude)
  }
  
  public func adding(coordinate: Coordinate) -> Coordinate {
    return self
      .adding(latitude: coordinate.latitude)
      .adding(longitude: coordinate.longitude)
  }
  
  public func toLocation() -> CLLocation {
    return CLLocation(latitude: self.latitude, longitude: self.longitude)
  }
}

public struct Settings {
  public private(set) var coordinate: Coordinate
  public private(set) var updateInterval: TimeInterval
  
  public init(coordinate: Coordinate, updateInterval: TimeInterval) {
    self.coordinate = coordinate
    self.updateInterval = updateInterval
  }
  
  public init() {
    self.init(coordinate: Coordinate(latitude: 0, longitude: 0),
              updateInterval: 0)
  }
  
  private init(_ settings: Settings) {
    self.init(coordinate: settings.coordinate,
              updateInterval: settings.updateInterval)
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
  
  public func with(updateInterval: TimeInterval) -> Settings {
    var copy = Settings(self)
    copy.updateInterval = updateInterval
    return copy
  }
}
