//
//  NavigationController.swift
//  IOSARSample
//
//  Created by Viethai Pham on 11/6/19.
//  Copyright © 2019 swiften. All rights reserved.
//

import SwiftRedux
import UIKit

public final class NavigationController: UINavigationController {
  var injector: PropInjector<AppState>!
  
  override public func viewDidLoad() {
    super.viewDidLoad()
    self.delegate = self
  }
}

// MARK: - UINavigationControllerDelegate
extension NavigationController: UINavigationControllerDelegate {
  public func navigationController(_ navigationController: UINavigationController,
                                   willShow viewController: UIViewController,
                                   animated: Bool) {
    switch viewController {
    case let vc as SettingViewController:
      self.injector.injectProps(controller: vc, outProps: ())
      
    case let vc as ARViewController:
      self.injector.injectProps(controller: vc, outProps: ())

    default:
      fatalError()
    }
  }
}
