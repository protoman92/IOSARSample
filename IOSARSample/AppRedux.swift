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
  case destination(Coordinate)
  case destinationAddress(String)
}

public struct AppState {
  public fileprivate(set) var origin: Coordinate
  public fileprivate(set) var destination: Coordinate
  public fileprivate(set) var destinationAddress: String
  
  public init() {
    self.origin = Coordinate(latitude: 0, longitude: 0)
    self.destination = Coordinate(latitude: 0, longitude: 0)
    self.destinationAddress = ""
  }
}

public final class AppReducer {
  public static func reduce(state: AppState, action: ReduxActionType) -> AppState {
    var newState = state
    
    switch action as? AppAction {
    case .some(.destination(let coordinate)):
      newState.destination = coordinate
      
    case .some(.destinationAddress(let address)):
      newState.destinationAddress = address
      
    default:
      break
    }
    
    return newState
  }
}

public final class AppSaga {
  public static func searchDestination(oneMapClient: OneMapClient) -> SagaEffect<()> {
    return SagaEffects.takeLatest(paramExtractor: { (action: AppAction) -> String? in
      switch action {
      case .destinationAddressQuery(let query): return query
      default: return nil
      }
    }, effectCreator: { query in
      return SagaEffects.await { input in
        do {
          let reversed = try SagaEffects
            .call(oneMapClient.reverseGeocode(query: query))
            .await(input)
          
          let result = try reversed.results.first.getOrThrow("")
          let destination = try result.toCoordinate().getOrThrow("")
          let address = result.ADDRESS
          SagaEffects.put(AppAction.destination(destination)).await(input)
          SagaEffects.put(AppAction.destinationAddress(address)).await(input)
        } catch {
          print(error)
        }
      }
    }, options: TakeOptions.builder().with(debounce: 1).build())
  }
}
