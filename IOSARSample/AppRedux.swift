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
  case routeInstructions([RouteInstruction])
  case routeIndex(Int)
  case currentRoute(RouteInstruction)
  
  case triggerStartRouting
  case triggerStopRouting
  case triggerNextRoute
  case triggerPrevRoute
}

public struct AppState {
  public fileprivate(set) var origin: Place
  public fileprivate(set) var destination: Place
  public fileprivate(set) var routeInstructions: [RouteInstruction]
  public fileprivate(set) var routeIndex: Int
  
  public init() {
    self.destination = Place(address: "", coordinate: .zero)
    self.origin = Place(address: "", coordinate: .zero)
    self.routeInstructions = []
    self.routeIndex = 0
  }
  
  public func currentRoute() -> RouteInstruction? {
    if self.routeIndex >= 0 && self.routeIndex < self.routeInstructions.count {
      return self.routeInstructions[self.routeIndex]
    }
    
    return nil
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
      
    case .some(.routeInstructions(let instructions)):
      newState.routeInstructions = instructions
      
    case .some(.routeIndex(let index)):
      newState.routeIndex = index
      
    default:
      break
    }
    
    return newState
  }
}

public final class AppSaga {
  public static func searchOrigin(geoClient: GeoClient) -> SagaEffect<()> {
    return SagaEffects
      .takeAction({(action: AppAction) -> String? in
        switch action {
        case .originAddressQuery(let query): return query
        default: return nil
        }
      })
      .debounce(bySeconds: 0.5)
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
      .takeAction({(action: AppAction) -> String? in
        switch action {
        case .destinationAddressQuery(let query): return query
        default: return nil
        }
      })
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
  
  public static func startRouting(geoClient: GeoClient) -> SagaEffect<()> {
    return SagaEffects
      .takeAction({(action: AppAction) -> Bool? in
        switch action {
        case .triggerStartRouting: return true
        case .triggerStopRouting: return false
        default: return nil
        }
      })
      .debounce(bySeconds: 0.5)
      .switchMap({valid in
        return SagaEffects.await(with: {input in
          guard valid else {
            SagaEffects.put(AppAction.routeInstructions([])).await(input)
            SagaEffects.put(AppAction.routeIndex(0)).await(input)
            return
          }
          
          let origin = SagaEffects
            .select(type: AppState.self)
            .await(input)
            .origin.coordinate

          let destination = SagaEffects
            .select(type: AppState.self)
            .await(input)
            .destination.coordinate
          
          do {
            let instructions = try SagaEffects
              .call(geoClient.route(start: destination, end: origin))
              .await(input)

            SagaEffects.put(AppAction.routeInstructions(instructions)).await(input)
          } catch {
            print(error)
          }
        })
      })
  }
  
  public static func showCurrentRoute() -> SagaEffect<()> {
    return SagaEffects
      .takeAction({(action: AppAction) -> Int? in
        switch action {
        case .triggerNextRoute: return 1
        case .triggerPrevRoute: return -1
        default: return nil
        }
      })
      .switchMap({change in
        return SagaEffects.await(with: {input in
          let routes = SagaEffects
            .select(type: AppState.self)
            .await(input)
            .routeInstructions
          
          let routeIndex = SagaEffects
            .select(type: AppState.self)
            .await(input)
            .routeIndex
          
          let newIndex = routeIndex + change
          
          if newIndex < routes.count && newIndex >= 0 {
            SagaEffects.put(AppAction.routeIndex(newIndex)).await(input)
          }
        })
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
  
  public static func showRoutes() -> SagaEffect<()> {
    return SagaEffects
      .takeAction({(action: AppAction) -> [RouteInstruction]? in
        switch action {
        case .routeInstructions(let instructions): return instructions
        default: return nil
        }
      })
      .switchMap({(instructions) -> SagaEffect<()> in
        return SagaEffects.await(with: {input in
          for instruction in instructions {
            SagaEffects.put(AppAction.currentRoute(instruction)).await(input)
            SagaEffects.delay(bySeconds: 2).await(input)
          }
        })
      })
  }
}
