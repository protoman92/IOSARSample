//
//  CoordinateSimulator.swift
//  IOSARSample
//
//  Created by Viethai Pham on 18/5/19.
//  Copyright © 2019 swiften. All rights reserved.
//

import Foundation

public final class CoordinateSimulator {
  private let lock = NSLock()
  private var timer: Timer?
  private var coordinateCallbacks: [(Coordinate) -> Void] = []
  private var coordinate: Coordinate
  
  public var simulatedCoordinate: Coordinate {
    self.lock.lock()
    defer { self.lock.unlock() }
    return self.coordinate
  }
  
  public init(settings: Settings) {
    self.coordinate = settings.targetCoordinate
    let updateInterval = settings.updateInterval / 1000
    self.timer = nil

    self.timer = Timer.scheduledTimer(
      withTimeInterval: updateInterval,
      repeats: true
    ) {[weak self] _ in self?.coordinateUpdated()}
  }
  
  public func on(coordinateChanged cb: @escaping (Coordinate) -> Void) {
    self.lock.lock()
    defer { self.lock.unlock() }
    self.coordinateCallbacks.append(cb)
    cb(self.coordinate)
  }
  
  private func coordinateUpdated() {
    var changed = 0.0001

    if Bool.random() {
      changed = -changed
    }

    let newCoordinate = self.coordinate
      .adding(latitude: changed)
      .adding(longitude: changed)

    self.lock.lock()
    defer { self.lock.unlock() }
    self.coordinate = newCoordinate
    self.coordinateCallbacks.forEach({$0(newCoordinate)})
  }
}
