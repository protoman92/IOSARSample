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
  private let lock = NSLock()
  private var lastAnchor: ARAnchor?
  
  override public func viewDidLoad() {
    super.viewDidLoad()
    self.sceneView.delegate = self
    self.sceneView.session.delegate = self

    LocationManager.instance.on(locationChange: {[weak self] in
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
    let session = self.sceneView.session
    guard let currentFrame = session.currentFrame else { return }
    self.showVisual(session, currentFrame, location)
  }
  
  private func showVisual(_ session: ARSession,
                          _ frame: ARFrame,
                          _ currentLocation: CLLocation) {
    self.lock.lock()
    defer { self.lock.unlock() }
    self.lastAnchor.map(session.remove)
    let start = Coordinate(location: currentLocation)
    let end = self.settings.coordinate
    let distance = Calculation.haversineM(start: start, end: end)
    
    let transform = MatrixTransformer()
      .translate(x: 0, y: 0, z: -distance / 10)
      .rotateY(radian: -Calculation.bearingRadian(start: start, end: end))
      .transform(frame.camera.transform)
    
    let anchor = ARAnchor(transform: transform)
    self.lastAnchor = anchor
    self.sceneView.session.add(anchor: anchor)
  }
}

// MARK: - ARSCNViewDelegate
extension ARViewController: ARSCNViewDelegate {
  public func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
    let box = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
    let boxNode = SCNNode(geometry: box)
    return boxNode
  }
}

// MARK: - ARSessionDelegate
extension ARViewController: ARSessionDelegate {
  public func session(_ session: ARSession, didUpdate frame: ARFrame) {
    guard let location = LocationManager.instance.lastLocation else { return }
    self.showVisual(session, frame, location)
  }
}
