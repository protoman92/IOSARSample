//
//  Matrix+Extension.swift
//  IOSARSample
//
//  Created by Viethai Pham on 18/5/19.
//  Copyright © 2019 swiften. All rights reserved.
//

import ARKit
import Foundation
import GLKit

private func glMatrixToMatrix(_ matrix: GLKMatrix4) -> simd_float4x4 {
  return simd_float4x4(
    float4(matrix.m00, matrix.m01, matrix.m02, matrix.m03),
    float4(matrix.m10, matrix.m11, matrix.m12, matrix.m13),
    float4(matrix.m20, matrix.m21, matrix.m22, matrix.m23),
    float4(matrix.m30, matrix.m31, matrix.m32, matrix.m33))
}

public struct MatrixTransformer {
  private let matrix: simd_float4x4
  private let transformers: [simd_float4x4]
  
  public init(_ matrix: simd_float4x4, _ transformers: [simd_float4x4] = []) {
    self.matrix = matrix
    self.transformers = transformers
  }
  
  public func appending(transformer: simd_float4x4) -> MatrixTransformer {
    var tfCopy = self.transformers
    tfCopy.append(transformer)
    return MatrixTransformer(matrix, tfCopy)
  }
  
  public func translate<BX, BY, BZ>(x: BX, y: BY, z: BZ) -> MatrixTransformer where
    BX: BinaryFloatingPoint, BY: BinaryFloatingPoint, BZ: BinaryFloatingPoint
  {
    var identity = matrix_identity_float4x4
    identity.columns.3.x = Float(x)
    identity.columns.3.y = Float(y)
    identity.columns.3.z = Float(z)
    return self.appending(transformer: identity)
  }
  
  public func rotateX<B>(radian: B) -> MatrixTransformer where B: BinaryFloatingPoint {
    let identity = GLKMatrix4RotateX(GLKMatrix4Identity, Float(radian))
    return self.rotate(identity)
  }
  
  public func rotateX<B>(degree: B) -> MatrixTransformer where B: BinaryFloatingPoint {
    return self.rotateX(radian: Calculation.degreeToRadian(degree))
  }
  
  public func rotateY<B>(radian: B) -> MatrixTransformer where B: BinaryFloatingPoint {
    let identity = GLKMatrix4RotateY(GLKMatrix4Identity, Float(radian))
    return self.rotate(identity)
  }
  
  public func rotateY<B>(degree: B) -> MatrixTransformer where B: BinaryFloatingPoint {
    return self.rotateY(radian: Calculation.degreeToRadian(degree))
  }
  
  public func rotateZ<B>(radian: B) -> MatrixTransformer where B: BinaryFloatingPoint {
    let identity = GLKMatrix4RotateZ(GLKMatrix4Identity, Float(radian))
    return self.rotate(identity)
  }
  
  public func rotateZ<B>(degree: B) -> MatrixTransformer where B: BinaryFloatingPoint {
    return self.rotateZ(radian: Calculation.degreeToRadian(degree))
  }
  
  public func transform() -> simd_float4x4 {
    let transformer = self.transformers.reduce(matrix_identity_float4x4, simd_mul)
    return simd_mul(self.matrix, transformer)
  }
  
  private func rotate(_ matrix: GLKMatrix4) -> MatrixTransformer {
    let transformer = simd_float4x4(
      float4(matrix.m00, matrix.m01, matrix.m02, matrix.m03),
      float4(matrix.m10, matrix.m11, matrix.m12, matrix.m13),
      float4(matrix.m20, matrix.m21, matrix.m22, matrix.m23),
      float4(matrix.m30, matrix.m31, matrix.m32, matrix.m33))
    
    return self.appending(transformer: transformer)
  }
}
