//
//  LocationManager.swift
//  IOSARSample
//
//  Created by Viethai Pham on 18/5/19.
//  Copyright © 2019 swiften. All rights reserved.
//

import CoreLocation

public final class LocationManager: NSObject {
  private let locationManager: CLLocationManager
  private let lock = NSLock()
  private var locationCallbacks = [(CLLocation) -> Void]()
  public private(set) var lastLocation: CLLocation?
  
  override public init() {
    self.locationManager = CLLocationManager()
    super.init()
    self.locationManager.delegate = self
    self.locationManager.requestWhenInUseAuthorization()
    self.locationManager.startUpdatingLocation()
  }
  
  public func register(locationCallback cb: @escaping (CLLocation) -> Void) {
    self.lock.lock()
    defer { self.lock.unlock() }
    self.locationCallbacks.append(cb)
    self.lastLocation.map(cb)
  }
}

extension LocationManager: CLLocationManagerDelegate {
  public func locationManager(_ manager: CLLocationManager,
                              didUpdateLocations locations: [CLLocation]) {
    self.lock.lock()
    defer { self.lock.unlock() }
    guard let location = locations.first else { return }
    self.lastLocation = location
    self.locationCallbacks.forEach({$0(location)})
  }
}
