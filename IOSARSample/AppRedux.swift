//
//  AppRedux.swift
//  IOSARSample
//
//  Created by Viethai Pham on 10/6/19.
//  Copyright © 2019 swiften. All rights reserved.
//

import SwiftRedux

public enum AppAction: ReduxActionType {
  case destinationAddressQuery(String)
}

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

public final class AppSaga {
  public static func searchDestination(oneMapClient: OneMapClient) -> SagaEffect<()> {
    return SagaEffects.takeLatest(paramExtractor: { (action: AppAction) -> String? in
      switch action {
      case .destinationAddressQuery(let query): return query
      }
    }, effectCreator: { query in
      return SagaEffects.await { input in
        do {
          let result = try SagaEffects
            .call(oneMapClient.reverseGeocode(query: query))
            .await(input)
          
          print(result)
        } catch {
          print(error)
        }
      }
    }, options: TakeOptions.builder().with(debounce: 1).build())
  }
}
