//
//  QRScanner.swift
//  ARKit-QRScanner
//
//  Created by Max Cobb on 11/15/18.
//  Copyright © 2018 Max Cobb. All rights reserved.
//

import ARKit

public enum QRPositionAccuracy {
  case guess
  case distanceApprox
}

public struct QRResponse {
  public let feature: CIQRCodeFeature
  public let position: SCNVector3
  public let hitResult: ARHitTestResult
  public let accuracy: QRPositionAccuracy
}

public final class QRScanner {
  private let detector: CIDetector
  
  public init(_ detector: CIDetector) {
    self.detector = detector
  }
  
  /// Return just the QR code information given a [CVPixelBuffer](apple-reference-documentation://hsVf8OXaJX)
  ///
  /// - Parameter buffer: Image of type CIImage from any source
  /// - Returns: A CoreImage QR code feature
  public func findQR(in image: CIImage) -> [CIQRCodeFeature] {
    return self.detector.features(in: image) as? [CIQRCodeFeature] ?? []
  }
  
  /// Return just the QR code information given a [CVPixelBuffer](apple-reference-documentation://hsVf8OXaJX)
  ///
  /// - Parameter buffer: [CVPixelBuffer](apple-reference-documentation://hsVf8OXaJX), provided by ARframe
  /// - Returns: A CoreImage QR code feature
  public func findQR(in buffer: CVPixelBuffer) -> [CIQRCodeFeature] {
    return self.findQR(in: CIImage(cvPixelBuffer: buffer))
  }

  /// Return a list of QR Codes and positions
  ///
  /// - Parameter frame: ARFrame provided by ARKit
  /// - Returns: A QRResponse array containing the estimated position, feature and accuracy
  public func findQR(in frame: ARFrame) -> [QRResponse] {
    let features = self.findQR(in: frame.capturedImage)
    let camTransform = frame.camera.transform
    
    let cameraPosition = SCNVector3(
      camTransform.columns.3.x,
      camTransform.columns.3.y,
      camTransform.columns.3.z
    )
    
    return features
      .compactMap({ feature -> (ARHitTestResult, CIQRCodeFeature)? in
        let posInFrame = CGPoint(
          x: (feature.bottomLeft.x + feature.topRight.x) / 2,
          y: (feature.bottomLeft.y + feature.topRight.y) / 2
        )
        
        let hitResults = frame.hitTest(
          posInFrame,
          types: [
            .estimatedVerticalPlane,
            .estimatedHorizontalPlane,
            .existingPlane, .featurePoint
          ])
        
        return hitResults.first.map({($0, feature)})
      })
      .compactMap({$0})
      .map({ (hitResult, feature) in
        let distanceInfront = hitResult.distance
        
        let camForward = SCNVector3(
          camTransform.columns.2.x,
          camTransform.columns.2.y,
          camTransform.columns.2.z
          ).setLength(Float(-distanceInfront))
        
        return QRResponse(
          feature: feature,
          position: SCNVector3(
            cameraPosition.x + camForward.x,
            cameraPosition.y + camForward.y,
            cameraPosition.z + camForward.z),
          hitResult: hitResult,
          accuracy: .distanceApprox)
        // The transform matrix is always coming back with tiny numbers
        //      let col3 = firstResult.worldTransform.columns.3
        //      return SCNVector3(
        //        col3.x,
        //        col3.y,
        //        col3.z
        //      )
      })
  }
}
