//
//  AppRedux.swift
//  IOSARSample
//
//  Created by Viethai Pham on 10/6/19.
//  Copyright © 2019 swiften. All rights reserved.
//

import SwiftRedux

public struct AppState {
  public let origin: Coordinate
  public let destination: Coordinate
  
  public init() {
    self.origin = Coordinate(latitude: 0, longitude: 0)
    self.destination = Coordinate(latitude: 0, longitude: 0)
  }
}

public final class AppReducer {
  public static func reduce(state: AppState, action: ReduxActionType) -> AppState {
    return state
  }
}
