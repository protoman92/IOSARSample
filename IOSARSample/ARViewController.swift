//
//  ARViewController.swift
//  IOSARSample
//
//  Created by Hai Pham on 16/5/19.
//  Copyright © 2019 swiften. All rights reserved.
//

import ARKit
import CoreLocation
import SwiftRedux
import UIKit

public final class ARViewController: UIViewController {
  @IBOutlet private weak var sceneView: ARSCNView!
  @IBOutlet private weak var infoLbl: UILabel!
  
  public var staticProps: StaticProps!
  
  public var reduxProps: ReduxProps? {
    didSet { self.reduxProps.map(self.didSetProps) }
  }
  
  private let lock = NSLock()
  private var lastAnchor: ARAnchor?
  
  override public func viewDidLoad() {
    super.viewDidLoad()
    self.sceneView.delegate = self
    self.sceneView.session.delegate = self
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
  
  private func showVisual(_ session: ARSession,
                          _ frame: ARFrame,
                          _ start: Coordinate,
                          _ end: Coordinate) {
    self.lock.lock()
    defer { self.lock.unlock() }
    self.lastAnchor.map(session.remove)
    let distance = start.toLocation().distance(from: end.toLocation())
    let optimalDistance = min(distance, Constants.MAX_AR_DISTANCE_IN_METER)
  
    let transform = MatrixTransformer()
      .translate(x: 0, y: 0, z: -optimalDistance)
      .rotateAroundY(radian: -Calculation.bearingRadian(start: start, end: end))
      .transformer()
    
    let anchor = ARAnchor(transform: transform)
    self.lastAnchor = anchor
    self.sceneView.session.add(anchor: anchor)
  }
  
  private func didSetProps(_ props: ReduxProps) {
    if props.firstInstance {
      props.action.startRouting()
    }
    
    self.infoLbl.text = props.state.currentRoute.street
    let session = self.sceneView.session
    guard let frame = session.currentFrame else { return }
    let origin = props.state.origin.coordinate
    let destination = props.state.currentRoute.coordinate
    self.showVisual(session, frame, origin, destination)
  }
}

// MARK: - PropContainerType
extension ARViewController: PropContainerType {
  public typealias GlobalState = AppState
  public typealias OutProps = Void
  
  public struct StateProps: Equatable {
    public let origin: Place
    public let destination: Place
    public let currentRoute: RouteInstruction
  }
  
  public struct ActionProps {
    public let startRouting: () -> Void
  }
}

// MARK: - PropMapperType
extension ARViewController: PropMapperType {
  public static func mapState(state: GlobalState, outProps: OutProps) -> StateProps {
    return StateProps(origin: state.origin,
                      destination: state.destination,
                      currentRoute: state.currentRoute)
  }
  
  public static func mapAction(dispatch: @escaping ReduxDispatcher,
                               state: GlobalState,
                               outProps: OutProps) -> ActionProps {
    return ActionProps(
      startRouting: {dispatch(AppAction.triggerStartRouting)}
    )
  }
}

// MARK: - ARSCNViewDelegate
extension ARViewController: ARSCNViewDelegate {
  public func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
    let box = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.1)
    let boxNode = SCNNode(geometry: box)
    return boxNode
  }
}

// MARK: - ARSessionDelegate
extension ARViewController: ARSessionDelegate {}
