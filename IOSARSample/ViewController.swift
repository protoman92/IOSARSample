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
  
  override public func viewDidLoad() {
    super.viewDidLoad()
    
    if !ARConfiguration.isSupported {
      print("AR is not supported on this device :(")
    }
    
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
  public func session(_ session: ARSession, didUpdate frame: ARFrame) {
    DispatchQueue.global(qos: .background).async {
      let qrResponses = QRScanner.findQR(in: frame)
      
      for response in qrResponses {
        print(response.feature.messageString ?? "no message found")
      }
    }
  }
}
