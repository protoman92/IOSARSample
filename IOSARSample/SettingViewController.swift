//
//  SettingViewController.swift
//  IOSARSample
//
//  Created by Viethai Pham on 18/5/19.
//  Copyright © 2019 swiften. All rights reserved.
//

import CoreLocation
import SwiftRedux
import UIKit

fileprivate extension Coordinate {
  init(offset: Double) {
    self.init(latitude: offset, longitude: offset)
  }
}

public final class SettingViewController: UIViewController {
  @IBOutlet weak var searchAddressTF: UITextField!
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
  
  @IBAction func searchAddressQueryChanged(_ sender: UITextField) {
    sender.text.map({self.reduxProps?.action.updateSearchAddressQuery($0)})
  }
  
  @objc func visualize() {}
  
  private func didSetProps(_ props: ReduxProps) {
    let state = props.state
    
    let infoText = """
    Target address: \(state.destinationAddress)
    Target latitude: \(state.destination.latitude)
    Target longitude: \(state.destination.longitude)
    """
    
    infoTV.text = infoText
  }
}

// MARK: - PropContainerType
extension SettingViewController: PropContainerType {
  public typealias GlobalState = AppState
  
  public typealias OutProps = Void
  
  public struct StateProps: Equatable {
    public let destination: Coordinate
    public let destinationAddress: String
  }
  
  public struct ActionProps {
    public let updateSearchAddressQuery: (String) -> Void
  }
}

// MARK: - PropMapperType
extension SettingViewController: PropMapperType {
  public static func mapState(state: GlobalState, outProps: OutProps) -> StateProps {
    return StateProps(
      destination: state.destination,
      destinationAddress: state.destinationAddress
    )
  }
  
  public static func mapAction(dispatch: @escaping ReduxDispatcher,
                               state: GlobalState,
                               outProps: OutProps) -> ActionProps {
    return ActionProps(
      updateSearchAddressQuery: {dispatch(AppAction.destinationAddressQuery($0))}
    )
  }
}
