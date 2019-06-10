//
//  Data.swift
//  IOSARSample
//
//  Created by Viethai Pham on 18/5/19.
//  Copyright © 2019 swiften. All rights reserved.
//

import CoreLocation

public struct Coordinate: Equatable {
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
  public private(set) var targetCoordinate: Coordinate
  public private(set) var updateInterval: TimeInterval
  public private(set) var visualizeOnce: Bool
  
  public init(targetCoordinate: Coordinate,
              updateInterval: TimeInterval,
              visualizeOnce: Bool) {
    self.targetCoordinate = targetCoordinate
    self.updateInterval = updateInterval
    self.visualizeOnce = visualizeOnce
  }
  
  public init() {
    self.init(targetCoordinate: Coordinate(latitude: 0, longitude: 0),
              updateInterval: 0,
              visualizeOnce: false)
  }
  
  private init(_ settings: Settings) {
    self.init(targetCoordinate: settings.targetCoordinate,
              updateInterval: settings.updateInterval,
              visualizeOnce: settings.visualizeOnce)
  }
  
  public func with(targetCoordinate: Coordinate) -> Settings {
    var copy = Settings(self)
    copy.targetCoordinate = targetCoordinate
    return copy
  }
  
  public func with(targetLatitude: Double) -> Settings {
    let targetCoordinate = self.targetCoordinate.with(latitude: targetLatitude)
    return self.with(targetCoordinate: targetCoordinate)
  }
  
  public func with(targetLongitude: Double) -> Settings {
    let targetCoordinate = self.targetCoordinate.with(longitude: targetLongitude)
    return self.with(targetCoordinate: targetCoordinate)
  }
  
  public func with(updateInterval: TimeInterval) -> Settings {
    var copy = Settings(self)
    copy.updateInterval = updateInterval
    return copy
  }
  
  public func should(visualizeOnce: Bool) -> Settings {
    var copy = Settings(self)
    copy.visualizeOnce = visualizeOnce
    return copy
  }
}
