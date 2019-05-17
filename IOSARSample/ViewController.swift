//
//  ViewController.swift
//  IOSARSample
//
//  Created by Hai Pham on 16/5/19.
//  Copyright © 2019 swiften. All rights reserved.
//

import ARKit
import UIKit

extension SCNMaterial {
  convenience init(color: UIColor) {
    self.init()
    diffuse.contents = color
  }
  
  convenience init(image: UIImage) {
    self.init()
    diffuse.contents = image
  }
}

public final class ViewController: UIViewController {
  @IBOutlet private weak var sceneKitView: ARSCNView!
  
  private lazy var qrScanner: QRScanner = {
    let detector = CIDetector.init(ofType: CIDetectorTypeQRCode, context: nil, options: nil)!
    return QRScanner(detector)
  }()
  
  private lazy var lastCallTime: TimeInterval = 0
  private lazy var lock: NSLock = NSLock()
  
  override public func viewDidLoad() {
    super.viewDidLoad()    
    self.sceneKitView.session.delegate = self
  }
  
  override public func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    let configuration = ARWorldTrackingConfiguration()
    self.sceneKitView.session.run(configuration)
  }
  
  override public func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    self.sceneKitView.session.pause()
  }
  
  private func calculateScene(_ response: QRResponse) -> SCNScene {
    let arrowPath = UIBezierPath.arrow(fromTip: response.position.twoDPoint(),
                                       length: 0.1,
                                       radianFromTip: 0.785398,
                                       tailWidth: 0.05,
                                       headWidth: 0.1,
                                       headLength: 0.05)

    let shape = SCNShape(path: arrowPath, extrusionDepth: 0)
    let arrowNode = SCNNode(geometry: shape)
    arrowNode.position = response.position

    let scene = SCNScene()
    scene.rootNode.addChildNode(arrowNode)
    return scene
  }
}

// MARK: - ARSessionDelegate
extension ViewController: ARSessionDelegate {
  
  /// We need to throttle the update because otherwise CIDetector will throw
  /// bad access (due to influx of updates).
  public func session(_ session: ARSession, didUpdate frame: ARFrame) {
    self.lock.lock()
    defer { self.lock.unlock() }
    let currentTime = Date().timeIntervalSince1970
    guard currentTime - self.lastCallTime > 1 else { return }
    self.lastCallTime = currentTime
    self.sceneKitView.scene.rootNode.childNodes.forEach({$0.removeFromParentNode()})

    self.qrScanner.findQR(in: frame).forEach({
      self.sceneKitView.scene = self.calculateScene($0)
    })
  }
}
