//
//  LocationManager.swift
//  IOSARSample
//
//  Created by Viethai Pham on 18/5/19.
//  Copyright © 2019 swiften. All rights reserved.
//

import CoreLocation

public final class LocationManager: NSObject {
  public static let instance = LocationManager()
  
  private let locationManager: CLLocationManager
  private let lock = NSLock()
  private var locationCallbacks = [(CLLocation) -> Void]()
  private var location: CLLocation?
  
  public var lastLocation: CLLocation? {
    self.lock.lock()
    defer { self.lock.unlock() }
    return self.location
  }
  
  override private init() {
    self.locationManager = CLLocationManager()
    super.init()
    self.locationManager.delegate = self
    self.locationManager.requestWhenInUseAuthorization()
    self.location = self.locationManager.location
    self.locationManager.startUpdatingLocation()
  }
  
  public func on(locationChange cb: @escaping (CLLocation) -> Void) {
    self.lock.lock()
    defer { self.lock.unlock() }
    self.locationCallbacks.append(cb)
    self.location.map(cb)
  }
}

extension LocationManager: CLLocationManagerDelegate {
  public func locationManager(_ manager: CLLocationManager,
                              didUpdateLocations locations: [CLLocation]) {
    self.lock.lock()
    defer { self.lock.unlock() }
    guard let location = locations.first else { return }
    self.location = location
    self.locationCallbacks.forEach({$0(location)})
  }
}
