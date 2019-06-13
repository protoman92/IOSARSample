//
//  SettingViewController.swift
//  IOSARSample
//
//  Created by Viethai Pham on 18/5/19.
//  Copyright © 2019 swiften. All rights reserved.
//

import SwiftRedux
import UIKit

public final class SettingViewController: UIViewController {
  @IBOutlet private weak var searchOriginTF: UITextField!
  @IBOutlet private weak var searchDestinationTF: UITextField!
  @IBOutlet private weak var infoTV: UITextView!
  
  public var staticProps: StaticProps!
  
  public var reduxProps: ReduxProps? {
    didSet { self.reduxProps.map(self.didSetProps) }
  }
  
  override public func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(
      title: "Visualize",
      style: .done,
      target: self,
      action: #selector(self.visualize))
  }
  
  @IBAction func originQueryChanged(_ sender: UITextField) {
    sender.text.map({self.reduxProps?.action.originQuery($0)})
  }
  
  @IBAction func destinationQueryChanged(_ sender: UITextField) {
    sender.text.map({self.reduxProps?.action.destinationQuery($0)})
  }
  
  @objc func visualize() {
    self.performSegue(withIdentifier: "visualize", sender: nil)
  }
  
  private func didSetProps(_ props: ReduxProps) {
    if props.firstInstance {
      self.searchDestinationTF.text = "Marina One"
      props.action.destinationQuery("Marina One")
    }
    
    let state = props.state
    
    let infoText = """
    Origin latitude: \(state.origin.coordinate.latitude)
    Origin longitude: \(state.origin.coordinate.longitude)
    Origin address: \(state.origin.address)
    
    _________________________________________________
    
    Destination latitude: \(state.destination.coordinate.latitude)
    Destination longitude: \(state.destination.coordinate.longitude)
    Destination address: \(state.destination.address)
    """
    
    infoTV.text = infoText
  }
}

// MARK: - PropContainerType
extension SettingViewController: PropContainerType {
  public typealias GlobalState = AppState
  
  public typealias OutProps = Void
  
  public struct StateProps: Equatable {
    public let destination: Place
    public let origin: Place
  }
  
  public struct ActionProps {
    public let destinationQuery: (String) -> Void
    public let originQuery: (String) -> Void
  }
}

// MARK: - PropMapperType
extension SettingViewController: PropMapperType {
  public static func mapState(state: GlobalState, outProps: OutProps) -> StateProps {
    return StateProps(destination: state.destination, origin: state.origin)
  }
  
  public static func mapAction(dispatch: @escaping ReduxDispatcher,
                               state: GlobalState,
                               outProps: OutProps) -> ActionProps {
    return ActionProps(
      destinationQuery: {dispatch(AppAction.destinationAddressQuery($0))},
      originQuery: {dispatch(AppAction.originAddressQuery($0))}
    )
  }
}
