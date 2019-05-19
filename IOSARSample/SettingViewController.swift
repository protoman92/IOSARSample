//
//  SettingViewController.swift
//  IOSARSample
//
//  Created by Viethai Pham on 18/5/19.
//  Copyright © 2019 swiften. All rights reserved.
//

import CoreLocation
import UIKit

fileprivate extension Coordinate {
  init(offset: Double) {
    self.init(latitude: offset, longitude: offset)
  }
}

public final class SettingViewController: UIViewController {
  @IBOutlet private weak var latitudeTF: UITextField!
  @IBOutlet private weak var longitudeTF: UITextField!
  @IBOutlet private weak var updateIntervalTF: UITextField!
  @IBOutlet private weak var visualizeOnceSw: UISwitch!
  @IBOutlet private weak var infoTV: UITextView!
  
  private var coordinateOffset = Coordinate(latitude: -0.0001, longitude: -0.02) {
    didSet { self.updateCurrentSettingInfo(nil) }
  }
  
  private var updateInterval: TimeInterval = 1000
  private var visualizeOnce: Bool = false
  
  override public func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(
      title: "Visualize",
      style: .done,
      target: self,
      action: #selector(self.visualize))
    
    self.latitudeTF.text = String(describing: coordinateOffset.latitude)
    self.longitudeTF.text = String(describing: coordinateOffset.longitude)
    self.updateIntervalTF.text = String(describing: self.updateInterval)
    
    LocationManager.instance.on(locationChange: {[weak self] in
      self?.onLocationChanged($0)
    })
  }
  
  override public func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.updateCurrentSettingInfo(nil)
  }
  
  override public func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    switch segue.destination {
    case let arController as ARViewController:
      let currentLocation = LocationManager.instance.lastLocation!
      
      let coordinate = Coordinate(location: currentLocation)
        .adding(coordinate: self.coordinateOffset)
      
      let settings = Settings(targetCoordinate: coordinate,
                              updateInterval: self.updateInterval,
                              visualizeOnce: self.visualizeOnce)
      
      let simulator = CoordinateSimulator(settings: settings)
      arController.simulator = simulator
      arController.settings = settings
      
    default:
      fatalError("Unexpeced segue to \(segue.identifier ?? "")")
    }
  }
  
  private func updateCurrentSettingInfo(_ location: CLLocation?) {
    let start = Coordinate(location: location ?? LocationManager.instance.lastLocation!)
    let end = self.targetCoordinate(start)
    
    let infoText = """
      Target latitude: \(end.latitude)
      Target longitude: \(end.longitude)
      Distance in meter: \(start.toLocation().distance(from: end.toLocation()))
      Bearing in degree: \(Calculation.bearingDegree(start: start, end: end))
    """
    
    self.infoTV.text = infoText
  }
  
  @IBAction func latitudeOffsetChanged(_ sender: UITextField) {
    sender.text.flatMap(Double.init).map({
      self.coordinateOffset = self.coordinateOffset.with(latitude: $0)
    })
  }
  
  @IBAction func longitudeOffsetChanged(_ sender: UITextField) {
    sender.text.flatMap(Double.init).map({
      self.coordinateOffset = self.coordinateOffset.with(longitude: $0)
    })
  }
  
  @IBAction func updateIntervalChanged(_ sender: UITextField) {
    sender.text.flatMap(TimeInterval.init).map({self.updateInterval = $0})
  }
  
  @IBAction func visualizeOnceChanged(_ sender: UISwitch) {
    self.visualizeOnce = sender.isOn
  }
  
  @objc func visualize() {
    self.performSegue(withIdentifier: "visualize", sender: nil)
  }
  
  private func onLocationChanged(_ location: CLLocation) {
    self.updateCurrentSettingInfo(location)
  }
  
  private func targetCoordinate(_ currentCoordinate: Coordinate) -> Coordinate {
    return currentCoordinate.adding(coordinate: self.coordinateOffset)
  }
}
