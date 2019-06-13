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
  case destination(Place)
  case destinationAddressQuery(String)
  case origin(Place)
  case originAddressQuery(String)
  
  case triggerStartRouting
}

public struct AppState {
  public fileprivate(set) var origin: Place
  public fileprivate(set) var destination: Place
  
  public init() {
    self.destination = Place(address: "", coordinate: .zero)
    self.origin = Place(address: "", coordinate: .zero)
  }
}

public final class AppReducer {
  public static func reduce(state: AppState, action: ReduxActionType) -> AppState {
    var newState = state
    
    switch action as? AppAction {
    case .some(.destination(let place)):
      newState.destination = place
      
    case .some(.origin(let place)):
      newState.origin = place
      
    default:
      break
    }
    
    return newState
  }
}

public final class AppSaga {
  public static func searchOrigin(geoClient: GeoClient) -> SagaEffect<()> {
    return SagaEffects
      .take({(action: AppAction) -> String? in
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
            let origin = try result.toCoordinate().getOrThrow("")
            let address = result.ADDRESS
            let place = Place(address: address, coordinate: origin)
            SagaEffects.put(AppAction.origin(place)).await(input)
          } catch {
            print(error)
          }
        }
      })
  }
  
  public static func searchDestination(geoClient: GeoClient) -> SagaEffect<()> {
    return SagaEffects
      .take({(action: AppAction) -> String? in
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
            let place = Place(address: address, coordinate: destination)
            SagaEffects.put(AppAction.destination(place)).await(input)
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
            let place = Place(address: "", coordinate: result)
            SagaEffects.put(AppAction.origin(place)).await(input)
          } catch {
            print(error)
          }
        }
      })
  }
  
  public static func startRouting(geoClient: GeoClient) -> SagaEffect<()> {
    return SagaEffects
      .take({(action: AppAction) -> Void? in
        switch action {
        case .triggerStartRouting: return ()
        default: return nil
        }
      })
      .switchMap({_ in
        return SagaEffects.await(with: {input in
          let origin = SagaEffects
            .select(fromType: AppState.self, {$0.origin.coordinate})
            .await(input)
          
          let destination = SagaEffects
            .select(fromType: AppState.self, {$0.destination.coordinate})
            .await(input)
          
          do {
            let instructions = try SagaEffects
              .call(geoClient.route(start: origin, end: destination))
              .await(input)
            
            print(instructions)
          } catch {
            print(error)
          }
        })
      })
  }
}
