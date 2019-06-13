//
//  Data.swift
//  IOSARSample
//
//  Created by Viethai Pham on 12/6/19.
//  Copyright © 2019 swiften. All rights reserved.
//

import CoreLocation

public struct Coordinate: Equatable {
  public static let zero = Coordinate(latitude: 0, longitude: 0)
  
  public static func fromString(_ coordinate: String) -> Coordinate {
    let degrees = coordinate
      .split(separator: ",")
      .map({$0.trimmingCharacters(in: .whitespaces)})
      .compactMap(Double.init)
    
    return Coordinate(latitude: degrees[0], longitude: degrees[1])
  }
  
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
  
  public func toString() -> String {
    return "\(self.latitude),\(self.longitude)"
  }
}

public struct Place: Equatable {
  public let address: String
  public let coordinate: Coordinate
}

public struct ReverseGeocoded: Decodable {
  public struct Result: Decodable {
    public let ADDRESS: String
    public let LATITUDE: String
    public let LONGITUDE: String
    
    public func toCoordinate() -> Coordinate? {
      return Double(self.LATITUDE).zipWith(Double(self.LONGITUDE), {
        return Coordinate(latitude: $0, longitude: $1)
      })
    }
  }
  
  public let found: Int
  public let pageNum: Int
  public let results: [Result]
}

public struct RouteInstruction {
  public let street: String
  public let coordinate: Coordinate
}
