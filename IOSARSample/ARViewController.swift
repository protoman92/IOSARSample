//
//  ARViewController.swift
//  IOSARSample
//
//  Created by Hai Pham on 16/5/19.
//  Copyright © 2019 swiften. All rights reserved.
//

import ARKit
import CoreLocation
import SwiftFP
import SwiftRedux
import UIKit

public final class ARViewController: UIViewController {
  @IBOutlet private weak var sceneView: ARSCNView!
  @IBOutlet private weak var infoLbl: UILabel!
  @IBOutlet private weak var progressContainer: UIView!
  
  deinit { self.reduxProps?.action.stopRouting() }
  
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
  
  @IBAction func nextClicked(_ sender: UIButton) {
    self.reduxProps?.action.nextInstruction()
  }
  
  @IBAction func prevClicked(_ sender: UIButton) {
    self.reduxProps?.action.prevInstruction()
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
    
    self.progressContainer.isHidden = !props.state.loading
    guard let currentRoute = props.state.currentRoute else { return }
    self.infoLbl.text = currentRoute.street
    let session = self.sceneView.session
    guard let frame = session.currentFrame else { return }
    let origin = props.state.origin.coordinate
    let destination = currentRoute.coordinate
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
    public let currentRoute: RouteInstruction?
    public let loading: Bool
  }
  
  public struct ActionProps {
    public let nextInstruction: () -> Void
    public let prevInstruction: () -> Void
    public let startRouting: () -> Void
    public let stopRouting: () -> Void
  }
}

// MARK: - PropMapperType
extension ARViewController: PropMapperType {
  public static func mapState(state: GlobalState, outProps: OutProps) -> StateProps {
    return StateProps(origin: state.origin,
                      destination: state.destination,
                      currentRoute: state.currentRoute(),
                      loading: state.loadingRoutes)
  }
  
  public static func mapAction(dispatch: @escaping ReduxDispatcher,
                               state: GlobalState,
                               outProps: OutProps) -> ActionProps {
    return ActionProps(
      nextInstruction: {dispatch(AppAction.triggerNextRoute)},
      prevInstruction: {dispatch(AppAction.triggerPrevRoute)},
      startRouting: {dispatch(AppAction.triggerStartRouting)},
      stopRouting: {dispatch(AppAction.triggerStopRouting)}
    )
  }
}

// MARK: - ARSCNViewDelegate
extension ARViewController: ARSCNViewDelegate {
  public func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
    guard let image = (self.reduxProps?.state.currentRoute?.icon)
      .flatMap({url in Try<Data>({try Data(contentsOf: url)}).value})
      .flatMap(UIImage.init)
      else {
        let box = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.1)
        let boxNode = SCNNode(geometry: box)
        return boxNode
    }
    
    let node = SCNNode()
    let imagePlane = SCNPlane(width: 0.1, height: 0.1)
    imagePlane.firstMaterial?.diffuse.contents = image.rounded()
    let imageNode = SCNNode(geometry: imagePlane)
    node.addChildNode(imageNode)
    return node
  }
}

// MARK: - ARSessionDelegate
extension ARViewController: ARSessionDelegate {}

fileprivate extension UIImage {
  func rounded() -> UIImage? {
    let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: self.size)
    UIGraphicsBeginImageContextWithOptions(self.size, false, 1)
    UIBezierPath(roundedRect: rect, cornerRadius: self.size.height).addClip()
    self.draw(in: rect)
    return UIGraphicsGetImageFromCurrentImageContext()
  }
}
