//
//  AppDelegate.swift
//  IOSARSample
//
//  Created by Hai Pham on 16/5/19.
//  Copyright © 2019 swiften. All rights reserved.
//

import RxSwift
import SwiftRedux
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
  {
    guard let topController = self.window?.rootViewController as? NavigationController else {
      fatalError()
    }
    
    let jsonDecoder = JSONDecoder()
    let geoClient = GeoClient(jsonDecoder: jsonDecoder, urlSession: URLSession.shared)
    
    let store = applyMiddlewares([
      SagaMiddleware(effects: [
        AppSaga.searchDestination(geoClient: geoClient),
        AppSaga.searchOrigin(geoClient: geoClient),
        AppSaga.startRouting(geoClient: geoClient),
        AppSaga.showCurrentRoute()
        ]).middleware
      ])(SimpleStore.create(AppState(), AppReducer.reduce))
    
    let injector = PropInjector(store: store)
    topController.injector = injector
    return true
  }

  func applicationWillResignActive(_ application: UIApplication) {}
  func applicationDidEnterBackground(_ application: UIApplication) {}
  func applicationWillEnterForeground(_ application: UIApplication) {}
  func applicationDidBecomeActive(_ application: UIApplication) {}
  func applicationWillTerminate(_ application: UIApplication) {}
}
