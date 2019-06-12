//
//  AppRedux.swift
//  IOSARSample
//
//  Created by Viethai Pham on 10/6/19.
//  Copyright © 2019 swiften. All rights reserved.
//

import RxSwift
import SwiftRedux

public enum AppAction: ReduxActionType {
  case destination(Coordinate)
  case destinationAddress(String)
  case destinationAddressQuery(String)
  case origin(Coordinate)
  case originAddress(String)
  case originAddressQuery(String)
}

public struct AppState {
  public fileprivate(set) var origin: Coordinate
  public fileprivate(set) var originAddress: String
  public fileprivate(set) var destination: Coordinate
  public fileprivate(set) var destinationAddress: String
  
  public init() {
    self.destination = Coordinate(latitude: 0, longitude: 0)
    self.destinationAddress = ""
    self.origin = Coordinate(latitude: 0, longitude: 0)
    self.originAddress = ""
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
      
    case .some(.origin(let coordinate)):
      newState.origin = coordinate
      
    case .some(.originAddress(let address)):
      newState.originAddress = address
      
    default:
      break
    }
    
    return newState
  }
}

public final class AppSaga {
  public static func searchOrigin(geoClient: GeoClient) -> SagaEffect<()> {
    return SagaEffects
      .take({ (action: AppAction) -> String? in
        switch action {
        case .originAddressQuery(let query): return query
        default: return nil
        }
      })
      .debounce(bySeconds: 1)
      .switchMap({ query in
        return SagaEffects.await { input in
          do {
            let reversed = try SagaEffects
              .call(geoClient.reverseGeocode(query: query))
              .await(input)
            
            let result = try reversed.results.first.getOrThrow("")
            let destination = try result.toCoordinate().getOrThrow("")
            let address = result.ADDRESS
            SagaEffects.put(AppAction.origin(destination)).await(input)
            SagaEffects.put(AppAction.originAddress(address)).await(input)
          } catch {
            print(error)
          }
        }
      })
  }
  
  public static func searchDestination(geoClient: GeoClient) -> SagaEffect<()> {
    return SagaEffects
      .take({ (action: AppAction) -> String? in
        switch action {
        case .destinationAddressQuery(let query): return query
        default: return nil
        }
      })
      .debounce(bySeconds: 1)
      .switchMap({ query in
        return SagaEffects.await { input in
          do {
            let reversed = try SagaEffects
              .call(geoClient.reverseGeocode(query: query))
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
      })
  }
  
  public static func streamLocation(lcManager: LocationManager) -> SagaEffect<()> {
    return SagaEffects
      .from(Observable<Coordinate>.create({obs in
        lcManager.on(locationChange: {
          obs.onNext(Coordinate(location: $0))
        })
        
        return Disposables.create {}
      }))
      .switchMap({ coordinate in
        return SagaEffects.await { input in
          do {
            let result = try coordinate.getOrThrow()
            SagaEffects.put(AppAction.origin(result)).await(input)
          } catch {
            print(error)
          }
        }
      })
  }
}
