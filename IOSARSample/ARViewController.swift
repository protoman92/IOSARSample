//
//  ARViewController.swift
//  IOSARSample
//
//  Created by Hai Pham on 16/5/19.
//  Copyright © 2019 swiften. All rights reserved.
//

import ARKit
import CoreLocation
import UIKit

public final class ARViewController: UIViewController {
  @IBOutlet private weak var sceneView: ARSCNView!
  
  public lazy var settings: Settings = Settings()
  private lazy var locationManager: LocationManager = LocationManager()
  private lazy var lastCallTime: TimeInterval = 0
  private lazy var lock: NSLock = NSLock()
  
  override public func viewDidLoad() {
    super.viewDidLoad()    
    self.sceneView.session.delegate = self

    self.locationManager.register(locationCallback: {[weak self] in
      self?.onLocationChange($0)
    })
  }
  
  override public func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    let configuration = ARWorldTrackingConfiguration()
    configuration.worldAlignment = .gravityAndHeading
    self.sceneView.session.run(configuration)
  }
  
  override public func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    self.sceneView.session.pause()
  }
  
  private func onLocationChange(_ location: CLLocation) {
    guard let currentFrame = self.sceneView.session.currentFrame else { return }
  }
}

// MARK: - ARSessionDelegate
extension ARViewController: ARSessionDelegate {
  
  /// We need to throttle the update because otherwise CIDetector will throw
  /// bad access (due to influx of updates).
  public func session(_ session: ARSession, didUpdate frame: ARFrame) {
    self.lock.lock()
    defer { self.lock.unlock() }
    let currentTime = Date().timeIntervalSince1970
    guard currentTime - self.lastCallTime > 1 else { return }
    self.lastCallTime = currentTime
  }
}
