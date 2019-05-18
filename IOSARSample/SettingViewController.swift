//
//  SettingViewController.swift
//  IOSARSample
//
//  Created by Viethai Pham on 18/5/19.
//  Copyright © 2019 swiften. All rights reserved.
//

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
  @IBOutlet private weak var infoTV: UITextView!
  
  private var coordinateOffset = Coordinate(offset: 0.0001) {
    didSet { self.coordinateOffsetChanged() }
  }
  
  private var updateInterval: TimeInterval = 1000
  
  private var currentCoordinate: Coordinate {
    let currentLocation = LocationManager.instance.lastLocation!
    return Coordinate(location: currentLocation)
  }
  
  private var targetCoordinate: Coordinate {
    return self.currentCoordinate.adding(coordinate: self.coordinateOffset)
  }
  
  override public func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(
      title: "Visualize",
      style: .done,
      target: self,
      action: #selector(self.visualize))

    self.latitudeTF.addTarget(
      self, action: #selector(self.latitudeOffsetChanged),
      for: .editingChanged)

    self.longitudeTF.addTarget(
      self, action: #selector(self.longitudeOffsetChanged),
      for: .editingChanged)
    
    self.updateIntervalTF.addTarget(
      self, action: #selector(self.updateIntervalChanged),
      for: .editingChanged)
    
    self.latitudeTF.text = String(describing: coordinateOffset.latitude)
    self.longitudeTF.text = String(describing: coordinateOffset.longitude)
    self.updateIntervalTF.text = String(describing: self.updateInterval)
  }
  
  override public func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.coordinateOffsetChanged()
  }
  
  override public func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    switch segue.destination {
    case let arController as ARViewController:
      let currentLocation = LocationManager.instance.lastLocation!
      
      let coordinate = Coordinate(location: currentLocation)
        .adding(coordinate: self.coordinateOffset)
      
      let settings = Settings(coordinate: coordinate,
                              updateInterval: self.updateInterval)
      
      let simulator = CoordinateSimulator(settings: settings)
      arController.simulator = simulator
      
    default:
      fatalError("Unexpeced segue to \(segue.identifier ?? "")")
    }
  }
  
  private func coordinateOffsetChanged() {
    let start = self.currentCoordinate
    let end = self.targetCoordinate
    
    let infoText = """
      Target latitude: \(end.latitude)
      Target longitude: \(end.longitude)
      Distance in meter: \(Calculation.haversineM(start: start, end: end))
      Bearing in degree: \(Calculation.bearingDegree(start: start, end: end))
    """
    
    self.infoTV.text = infoText
  }
  
  @objc func latitudeOffsetChanged(_ sender: UITextField) {
    sender.text.flatMap(Double.init).map({
      self.coordinateOffset = self.coordinateOffset.with(latitude: $0)
    })
  }
  
  @objc func longitudeOffsetChanged(_ sender: UITextField) {
    sender.text.flatMap(Double.init).map({
      self.coordinateOffset = self.coordinateOffset.with(longitude: $0)
    })
  }
  
  @objc func updateIntervalChanged(_ sender: UITextField) {
    sender.text.flatMap(TimeInterval.init).map({self.updateInterval = $0})
  }
  
  @objc func visualize() {
    self.performSegue(withIdentifier: "visualize", sender: nil)
  }
}
