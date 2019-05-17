//
//  ViewController.swift
//  IOSARSample
//
//  Created by Hai Pham on 16/5/19.
//  Copyright © 2019 swiften. All rights reserved.
//

import ARKit
import UIKit

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
    let qrResponses = self.qrScanner.findQR(in: frame)
    
    for response in qrResponses {
      print(response.feature.messageString ?? "no message found")
    }
  }
}
