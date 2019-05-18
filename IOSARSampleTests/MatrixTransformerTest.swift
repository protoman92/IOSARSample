//
//  MatrixTransformerTest.swift
//  IOSARSampleTests
//
//  Created by Viethai Pham on 19/5/19.
//  Copyright © 2019 swiften. All rights reserved.
//

import ARKit
import XCTest
@testable import IOSARSample

public final class MatrixTransformerTest: XCTestCase {
  public func test_transformSequence_shouldWork() {
    // Setup
    let original = simd_float4(x: 1, y: 0, z: 0, w: 1)
    
    // When
    let transformed = MatrixTransformer()
      .appending(transformer: matrix_identity_float4x4)
      .translate(x: 1, y: 0, z: 0)
      .scale(x: 3, y: 0, z: 0)
      .transform(original)
    
    // Then
    XCTAssertEqual(transformed, simd_float4(arrayLiteral: 6, 0, 0, 1))
  }
}
