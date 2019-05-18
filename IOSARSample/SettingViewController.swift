//
//  SettingViewController.swift
//  IOSARSample
//
//  Created by Viethai Pham on 18/5/19.
//  Copyright © 2019 swiften. All rights reserved.
//

import UIKit

public final class SettingViewController: UIViewController {
  @IBOutlet private weak var latitudeTF: UITextField!
  @IBOutlet private weak var longitudeTF: UITextField!
  
  private lazy var settings: Settings = Settings()
  
  override public func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(
      title: "Visualize",
      style: .done,
      target: self,
      action: #selector(self.visualize))

    self.latitudeTF.addTarget(self, action: #selector(self.latitudeChanged),
                              for: .editingChanged)

    self.longitudeTF.addTarget(self, action: #selector(self.longitudeChanged),
                               for: .editingChanged)
  }
  
  override public func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    switch segue.destination {
    case let arController as ARViewController:
      arController.settings = self.settings
      
    default:
      fatalError("Unexpeced segue to \(segue.identifier ?? "")")
    }
  }
  
  @objc func latitudeChanged(_ sender: UITextField) {
    sender.text.flatMap(Double.init).map({settings = settings.with(latitude: $0)})
  }
  
  @objc func longitudeChanged(_ sender: UITextField) {
    sender.text.flatMap(Double.init).map({settings = settings.with(longitude: $0)})
  }
  
  @objc func visualize() {
    self.performSegue(withIdentifier: "visualize", sender: nil)
  }
}
